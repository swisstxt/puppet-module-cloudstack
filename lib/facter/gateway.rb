Facter.add('gateway') do
  setcode do
    `ip route`[/default via ([\d+\.]+)/, 1]
  end
end

