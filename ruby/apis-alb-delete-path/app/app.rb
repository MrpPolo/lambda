#!/usr/bin/env ruby
require 'aws-sdk'

puts "event: #{ARGV[0]}"
puts "context: #{ARGV[1]}"

@ALB_ARN = ARGV[2]
puts @ALB_ARN
@TG_GROUP = ARGV[3]
puts @TG_GROUP
@PATH_PATTERN = ARGV[4]
puts @PATH_PATTERN

#init @v_array_count_1, @v_array_count_2
@v_array_count_1=0
@v_array_count_2=0
@HEALTH_CNT=0

elasticloadbalancingv2 = Aws::ElasticLoadBalancingV2::Client.new(region: 'ap-northeast-1')

#target group health check
apis_tg_health_cnt = elasticloadbalancingv2.describe_target_health({
                                                                       target_group_arn: @TG_GROUP,
                                                                   }).to_h

apis_tg_health_cnt[:target_health_descriptions].each do |instance|

  if instance[:target_health][:state] == "healthy"
    @HEALTH_CNT = @HEALTH_CNT + 1
  end

end

if @HEALTH_CNT > 0

  #get apis alb listener list
  apis_listeners =  elasticloadbalancingv2.describe_listeners(
      {
          load_balancer_arn: @ALB_ARN
      }
  )

  #loop apis alb listener list
  apis_listeners.listeners.each do |listener|

    @v_array_count_1=0
    @v_array_count_2=0

    #get apis alb listener rules list
    apis_elb_des_rule = elasticloadbalancingv2.describe_rules({
                                                                  listener_arn: listener.listener_arn,
                                                              }).to_h

      #compare rule with customer pattern & find customer rule index
      apis_elb_des_rule[:rules].each_with_index do |rules,index1|

          rules[:conditions].each_with_index do |conditions,index2|

            if conditions[:values][0]  == @PATH_PATTERN
              @v_array_count_2 = index2
            end

          end

          unless rules[:conditions][@v_array_count_2].nil?

            if rules[:conditions][@v_array_count_2][:values][0] == @PATH_PATTERN
              @v_array_count_1 = index1
            end

          end


      end

      #delete rules
      if apis_elb_des_rule[:rules][@v_array_count_1][:conditions][@v_array_count_2][:values][0] == @PATH_PATTERN
        puts @PATH_PATTERN
        apis_elb_delete_rule = elasticloadbalancingv2.delete_rule({
                                                                      rule_arn: apis_elb_des_rule[:rules][@v_array_count_1][:rule_arn]
                                                                  })
      end

  end

end
