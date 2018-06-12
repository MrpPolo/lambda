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

  apis_listeners =  elasticloadbalancingv2.describe_listeners(
      {
          load_balancer_arn: @ALB_ARN
      }
  )

    apis_listeners.listeners.each do |listener|

      apis_elb_create_rule = elasticloadbalancingv2.create_rule({
                                                                    actions: [{
                                                                                  target_group_arn: @TG_GROUP,
                                                                                  type: "forward",
                                                                              },],
                                                                    conditions: [{
                                                                                     field: "path-pattern",
                                                                                     values: [
                                                                                         @PATH_PATTERN,
                                                                                     ],
                                                                                 },],
                                                                    listener_arn: listener.listener_arn,
                                                                    priority: 10,
                                                                })

      puts apis_elb_create_rule.rules
    end

end
