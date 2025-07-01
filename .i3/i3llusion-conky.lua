os.setlocale("C", "numeric")

function conky_alignR(a, w)
 return string.format("%" .. w .. "." .. w .. "s", conky_parse(a))
end

function conky_toMbit(a, w)
 return string.format("%" .. w .."f", tonumber(conky_parse(a)) / 131072)
end

function conky_toMByte(a, w)
 return string.format("%" .. w .. "f", tonumber(conky_parse(a)) / 1048576)
end

function conky_memwithoutbufferstoMByte(m, b, c, w)
 return string.format("%" .. w .. "f", (tonumber(conky_parse(m)) - tonumber(conky_parse(b)) - tonumber(conky_parse(c))) / 1048576)
end
