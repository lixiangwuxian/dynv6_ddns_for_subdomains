local function init()
    key_name='tsig-123456.dynv6.com'
    key='ABCDEFG1234567=='
    method='hmac-YOUR_METHOD'
    zone='YOUR_DOMAIN.com'
    domain='abc.YOUR_DOMAIN.com'
end

local function getIPv4()
    local IPresult=io.popen("curl ip.changeip.com","r")
    local result = nil
    for result in IPresult:lines() do
        return result
    end
    return nil
end

local function getIPv6()
    local IPresult=io.popen("curl 'https://ipv6.lookup.test-ipv6.com/ip/?callback=_jqjsp&asn=1&testdomain=test-ipv6.com&testname=test_asn6'","r")
    io.input(IPresult)
    local IPresult=io.read()
    local tmp,startip,endip=nil,nil,nil
    tmp, startip=string.find(IPresult,'"ip":"')
    endip,tmp=string.find(IPresult,'","type')
    local result=string.sub(IPresult,startip+1,endip-1)
    return result
end

local function setIP(IP)
    local command_file=io.open("/tmp/"..IP..".NScommand","w")
    io.output(command_file)
    io.write("server ns1.dynv6.com\n")
    io.write("zone "..zone.."\n")
    io.write("update delete "..domain.." A\n")
    io.write("update add "..domain.." 60 A "..IP.."\n")
    io.write("key "..method..":"..key_name.." "..key.."\n")
    io.write("send\n")
    io.close(command_file)
    os.execute("nsupdate ".."/tmp/"..IP..".NScommand");
end

local function setIPv6(IP)
    local command_file=io.open("/tmp/"..IP..".NScommand","w")
    io.output(command_file)
    io.write("server ns1.dynv6.com\n")
    io.write("zone "..zone.."\n")
    io.write("update delete "..domain.." AAAA\n")
    io.write("update add "..domain.." 60 AAAA "..IP.."\n")
    io.write("key "..method..":"..key_name.." "..key.."\n")
    io.write("send\n")
    io.close(command_file)
    os.execute("nsupdate ".."/tmp/"..IP..".NScommand");
end

local function main()
    local lastIP=io.open("/tmp/previous_IP.list","r")
    io.input(lastIP)
    local lastIPv4=nil
    local lastIPv6=nil
    if lastIP~=nil then
        lastIPv4=io.read()
        lastIPv6=io.read()
    end
    local IPv4=getIPv4()
    if IPv4~=nil and IPv4~=lastIPv4 then
        setIP(IPv4)
        os.execute("rm /tmp/"..IPv4..".NScommand")
    end
    local IPv6=getIPv6()
    if IPv6~=nil and IPv6~=lastIPv6 then
        setIPv6(IPv6)
        os.execute("rm /tmp/"..IPv6..".NScommand")
    end
    local previous_IP_file=io.open("/tmp/previous_IP.list","w")
    io.output(previous_IP_file)
    io.write(IPv4.."\n")
    io.write(IPv6)
    io.close(previous_IP_file)
end

local function test()
    print(getIPv6())
end

--test()
init()
main()
