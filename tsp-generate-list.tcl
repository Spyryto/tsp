
#  list commands
#  lappend, lindex, llength, lrange, lset, list, lreplace, linsert


#########################################################
# generate code for "lset" command (assumed to be first parse word)
# varName must be a var type; string, int, boolean, double cause compile error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_lset {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 4} {
        ::tsp::addError compUnit "wrong # args: should be \"lset listVar index ?index...? value\""
        return [list void "" ""]
    }

    # varname must be text, must exists
    set varComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $varComponent type rawtext varname
    if {$type ne "text"} {
        ::tsp::addError compUnit "append varName not a text word: \"$rawtext\""
        return [list void "" ""]
    }
    set type [::tsp::getVarType compUnit $varname]
    if {$type eq "undefined"} {
        ::tsp::addError compUnit "can't read \"$varname\": no such variable"
        return [list void "" ""]
    }
    if {$type eq "array" || $type eq "string" || $type eq "boolean" || $type eq "int" || $type eq "double"} {
        ::tsp::addError compUnit "lset varName must be type var, defined as : $type"
        return [list void "" ""]
    }
    
    set code "\n/***** ::tsp::gen_command_lset */\n"
    # if varname was not previously included as volatile, spill variable here and add to volatile list
    if {[lsearch [dict get $compUnit volatile] $varname] == -1} {
        append code [::tsp::lang_spill_vars compUnit $varname] \n
        ::tsp::append_volatile_list compUnit $varname
    }

    # generate the code to call the command, and append to existing code
    set directResult [::tsp::gen_direct_tcl compUnit $tree]
    lassign [lindex $directResult] type rhsvar
    append code [lindex $directResult 2]

    return [list $type $rhsvar $code]
}


#########################################################
# generate code for "lappend" command (assumed to be first parse word)
# varName must be a var type; string, int, boolean, double cause compile error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_lappend {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 2} {
        ::tsp::addError compUnit "wrong # args: should be \"append varName ?value value ...?\""
        return [list void "" ""]
    }

    # varname must be text, must exists
    set varComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $varComponent type rawtext varname
    if {$type ne "text"} {
        ::tsp::addError compUnit "append varName not a text word: \"$rawtext\""
        return [list void "" ""]
    }

    set code "\n/***** ::tsp::gen_command_lappend */\n"
    set type [::tsp::getVarType compUnit $varname]
    if {$type eq "array" || $type eq "string" || $type eq "boolean" || $type eq "int" || $type eq "double"} {
        ::tsp::addError compUnit "append varName must be type var, defined as : $type"
        return [list void "" ""]
    }
    if {$type eq "undefined"} {
        ::tsp::addWarning compUnit "lappend varName \"$varname\" defined as var"
        append code [::tsp::lang_assign_empty_zero $varname var]
    }

    set tmpvar [::tsp::get_tmpvar compUnit var]
    set body [dict get $compUnit body]
    foreach node [lrange $tree 2 end] {
        # append to var
        set argrange [lindex $node 1]
        lassign $argrange start end
        set end [expr {$start + $end - 1}]
        set argtext [string range $body $start $end]
        set setBody "set $tmpvar $argtext"
        set dummyUnit [::tsp::init_compunit dummy dummy "" $setBody]
        lassign [parse command $setBody {0 end}] x x x setTree
        ::tsp::copyVars compUnit dummyUnit
        set setCode [::tsp::gen_command_set dummyUnit $setTree]
        append code [lindex $setCode 2]
        append code [::tsp::lang_lappend_var  __$varname $tmpvar]
    }
    
    # return the value
    return [list var __$varname $code]
}






#FIXME: compile other list commands
