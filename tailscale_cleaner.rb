require "json"
require "time"

def devices(key, email)
  json=`curl --silent --fail -L 'https://api.tailscale.com/api/v2/tailnet/#{email}/devices' -u "#{key}:"`
  devices = JSON.parse(json)["devices"]
end

def delete(key, id)
  `curl --silent -X DELETE 'https://api.tailscale.com/api/v2/device/#{id}' -u "#{key}:"`
end

email=ARGV[0]
key=ARGV[1]
hours=Float ARGV[2]
filter=ARGV[3]

deadline=hours * 60 * 60

devices(key, email).each do |d|
  hostname = d["hostname"]
  next unless hostname.include? filter

  last_seen = d["lastSeen"]
  delta = Time.now - Time.parse(last_seen)

  if delta > deadline
    pp [:delete, hostname, delta]
    delete(key, d["id"])
  else
    pp [:keep, hostname, (deadline-delta).round, :seconds_left]
  end
end