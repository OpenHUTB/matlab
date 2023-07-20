function[NameArray,ValueArray]=rbBlockPVPairsLadder(obj)

    newStr=lower(regexprep(obj.Topology,'ow|igh|and|ass|top|i|ee',''));
    NameArray={'LadderType',['Inductance_',newStr],['Capacitance_',newStr]};

    str=regexprep(obj.Topology,'(tee|pi)','${" "+$0}');
    Str="LC "+regexprep(str,'\<.','${upper($0)}');
    ValueArray={Str,['[',num2str(obj.Inductances),']'],['[',num2str(obj.Capacitances),']']};
end