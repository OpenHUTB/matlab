function newobj=copyobj(this)



    newobj=hdlcoderprops.HDLProps;


    newobj.CLI=copy(this.CLI);


    newobj.INI=copyINI(this.INI);

    hGC=newobj.INI.getPropSet('Global','Common');


    hListener=handle.listener(hGC,hGC.findprop('target_language'),...
    'PropertyPostSet',@(h,ed)targetLanguageChanged(newobj));
    set(newobj,'TargetLanguageListener',hListener);


    targetLanguageChanged(newobj);
end



function props=copyINI(hINI)





    names={'Common'};
    hGC=copy(hINI.getPropSet('Global','Common'));
    sets={hGC};
    Global=propset.leaf(names,sets);


    names={'Common'};
    sets={copy(hINI.getPropSet('TestBench','Common'))};
    TestBench=propset.leaf(names,sets);


    names={'Compilation','Mapping','Simulation','Synthesis','Projects'};
    hECo=copy(hINI.getPropSet('EDAScript','Compilation'));
    hEMa=copy(hINI.getPropSet('EDAScript','Mapping'));
    hESi=copy(hINI.getPropSet('EDAScript','Simulation'));
    hESy=copy(hINI.getPropSet('EDAScript','Synthesis'));
    hEPr=copy(hINI.getPropSet('EDAScript','Projects'));
    sets={hECo,hEMa,hESi,hESy,hEPr};

    EDAScript=propset.leaf(names,sets);

    Filter=propset.leaf({'Common'},{copy(hINI.getPropSet('Filter','Common'))});


    names={'Global','TestBench','EDAScript','Filter'};
    sets={Global,TestBench,EDAScript,Filter};
    props=propset.tree(names,sets);
end


