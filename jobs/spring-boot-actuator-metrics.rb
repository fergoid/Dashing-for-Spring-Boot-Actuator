require 'rest_client'
require 'json'
require 'logger'

success_requests = 0
not_found_requests = 0


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '10s', :first_in => 0 do |job|

  response = RestClient.get 'http://localhost:8080/metrics'
  @data = JSON.parse response.body
  heap_used = (@data['heap.used']+@data['nonheap.used'])/1000
  last_requests = success_requests
  last_not_found = not_found_requests
  success_requests = @data['counter.status.200.deals.id']
  unsuccess_requests = @data['counter.status.204.deals.id']
  not_found_requests = @data['counter.status.404.deals.id']
  total_requests = (success_requests || 0) + (unsuccess_requests || 0) + (not_found_requests || 0)
  success_rate = (success_requests.to_f / total_requests.to_f)*100
  send_event('heap_used', {value: heap_used})
  send_event('success', {current: success_requests, last: last_requests})
  send_event('no_content', {current: unsuccess_requests})
  send_event('not_found', {current: not_found_requests, last: last_not_found})
  send_event('synergy', {value: success_rate.round})
  send_event('total', {current: total_requests})

end
