function this=HDLProps(varargin)



    this=hdlcoderprops.HDLProps;


    this.INI=createINI;


    this.CLI=hdlcoderprops.CLI(varargin{:});

    hGC=this.INI.getPropSet('Global','Common');

    hListener=handle.listener(hGC,hGC.findprop('target_language'),...
    'PropertyPostSet',@(h,ed)targetLanguageChanged(this));
    set(this,'TargetLanguageListener',hListener);


    this.targetLanguageChanged;
end



function props=createINI





    names={'Common'};
    sets={hdlcoderprops.GlobalCommon};
    Global=propset.leaf(names,sets);


    names={'Common'};
    sets={hdlcoderprops.TestBenchCommon};
    TestBench=propset.leaf(names,sets);


    names={'Compilation','Mapping','Simulation','Synthesis','Projects'};
    sets={hdlcoderprops.EDACompilation...
    ,hdlcoderprops.EDAMapping...
    ,hdlcoderprops.EDASimulation...
    ,hdlcoderprops.EDASynthesis...
    ,hdlcoderprops.EDAProjects};
    EDAScript=propset.leaf(names,sets);

    Filter=propset.leaf({'Common'},{hdlcoderprops.FilterCommon});


    names={'Global','TestBench','EDAScript','Filter'};
    sets={Global,TestBench,EDAScript,Filter};
    props=propset.tree(names,sets);
end


