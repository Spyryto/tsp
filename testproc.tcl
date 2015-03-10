source tsp.tcl
tsp::proc foo {i} {
  #tsp::procdef int -args int
  return $i
}



source tsp.tcl
set body {
    #::tsp::procdef returns: int args: int string
    #::tsp::var sum 
    set i 10000
    set j $i
    return $i
    #puts hi
} ; format ""
set compUnit [::tsp::init_compunit FILE NAME {i s} $body] ; format ""
set code [::tsp::parse_body compUnit {0 end}] ; format ""
::tsp::lang_create_compilable compUnit $code



::tsp::proc foo {i s} {
    #::tsp::procdef returns: int args: int string
    set i 10000
    set j $i
    return $i
}


source tsp.tcl
proc callit {} {puts calledit}
::tsp::proc foo {} {
  #::tsp::procdef returns: void args:
  callit
}

proc callit {} {puts calledit}
::tsp::proc foo {} {
  #::tsp::procdef returns: void args:
  puts "hello world"
}

source tsp.tcl
::tsp::proc foo2 {a} {
  #::tsp::procdef returns: void args: int
  #::tsp::string b
  #::tsp::volatile a
  set b [::set a]
  puts $b
}


source tsp.tcl
set bing yeah
::tsp::proc foo3 {} {
  #::tsp::procdef returns: void args:
  upvar #0 bing foo
  puts $foo
  set foo didit!
}



source tsp.tcl
::tsp::proc foo2 {i} {
    #tsp::procdef returns: void args: int
    #tsp::int i
    #tsp::var v
    set v [expr {$i + 1}]
    puts $v
}
    
