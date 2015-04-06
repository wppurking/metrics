require "httparty"
require "multi_json"

BASE_URL = "http://docker.ip:8086"
DB = 'collectd'

def post_to_influxdb(data_body)
  resp = HTTParty.post("#{BASE_URL}/db/#{DB}/series", query: {u: 'root', p: 'root'}, body: MultiJson.encode(data_body))
  puts resp
end

def one_point(serie: 'foo', key: nil, val: nil)
  {
    # 定义好了默认的 foo series
    name: serie,
    # 这些结构与 ES 类似, 都是可以动态生成 scheme 的
    columns: ['time', 'key', 'val'],
    points: [
      [(Time.now.to_f * 1000).to_i, key, val]
    ]
  }
end


# 添加 100 个点
def  add100point
  data_body = []
  1.upto(100).each do |t|
    data_body.push(one_point(key: %w(a b c).sample, val: rand(100)))
    interval = rand
    puts "Add one point with Interval: #{interval}"
    sleep(interval)
  end
  post_to_influxdb(data_body)
end

# 一直添加点, 可通过 influxdb 看到实时数据
def loop_point
  loop do
    post_to_influxdb([one_point(key: %w(a b c).sample, val: rand(500))])
    interval = rand
    puts "Add one point to influxdb with Interval: #{interval}"
    sleep(interval)
  end
end

loop_point