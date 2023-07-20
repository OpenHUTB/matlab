function ckt=createrfcktfromblk(block)






    ckt=[];

    Udata=get_param(block,'UserData');
    if isempty(Udata)
        return
    end
    if isa(block,'char')
        datasource=block;
    else
        datasource=sprintf('%s/%s',get(block,'Path'),get(block,'Name'));
    end


    ckt=Udata.Ckt;
    if isa(ckt,'rfckt.rfckt')&&isvalid(ckt)
        data=get(ckt,'AnalyzedResult');
        if~isa(data,'rfbbequiv.data')
            setrfdata(ckt,rfbbequiv.data('CopyPropertyObj',false));
            data=get(ckt,'AnalyzedResult');
        end
    else
        data=rfbbequiv.data('CopyPropertyObj',false);
    end
    set(data,'Block',datasource);


    classname=get_param(block,'SubClassName');


    allEn=get_param(block,'MaskEnables');
    allPrompts=get_param(block,'MaskPrompts');
    MaskWSValues=rfblksgetblockmaskwsvalues(block);
    idxMaskNames=rfblksgetblockmaskparamsindex(block);



    fndStr=find(strcmpi(get_param(block,'MaskValues'),...
    'Determined from data source'));
    if~isempty(fndStr)
        maskNames=get_param(block,'MaskNames');
        parNames=maskNames(fndStr);
        for aName=parNames
            strName=aName{1};
            switch strName
            case{'OIP3','IIP3','P1dB','PSat'}
                set_param(block,strName,'inf')
                MaskWSValues.(strName)=inf;
            case{'GCSat'}
                set_param(block,strName,'3')
                MaskWSValues.(strName)=3;
            case{'NF','FMIN','NTemp'}
                set_param(block,strName,'0')
                MaskWSValues.(strName)=0;
            case{'RN','NFactor'}
                set_param(block,strName,'1')
                MaskWSValues.(strName)=1;
            case{'GammaOpt'}
                set_param(block,strName,'1+0i')
                MaskWSValues.(strName)=1+0i;
            case{'NoiseDataFreq','NonlinearDataFreq'}
                set_param(block,strName,'2.0e9')
                MaskWSValues.(strName)=2.0e9;
            end
        end
    end


    switch classname
    case 's-params-passive-network'
        if undefparam1({'NetParamData','NetParamFreq','Z0'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        interp=get_param(block,'InterpMethod');
        type='S_PARAMETERS';
        newNetData=MaskWSValues.NetParamData;
        newFreq=MaskWSValues.NetParamFreq;
        newFreq=checkvector(newFreq);
        newZ0=MaskWSValues.Z0;
        if~isa(ckt,'rfckt.passive')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.passive('File','');
        end
        netdata=rfdata.network;
        set(netdata,'Block',datasource,'Type',type,'Data',newNetData,...
        'Freq',newFreq,'Z0',newZ0);
        if~isa(ckt.AnalyzedResult,'rfbbequiv.data')
            setrfdata(ckt,data);
            data=get(ckt,'AnalyzedResult');
        end
        set(ckt,'Block',datasource,'IntpType',interp,...
        'NetworkData',netdata);
        restore(ckt);

    case 'y-params-passive-network'
        if undefparam1({'NetParamData','NetParamFreq'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        interp=get_param(block,'InterpMethod');
        type='Y_PARAMETERS';
        newNetData=MaskWSValues.NetParamData;
        newFreq=MaskWSValues.NetParamFreq;
        newFreq=checkvector(newFreq);
        if~isa(ckt,'rfckt.passive')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.passive('File','');
        end
        netdata=rfdata.network;
        set(netdata,'Block',datasource,'Type',type,'Data',newNetData,...
        'Freq',newFreq);
        if~isa(ckt.AnalyzedResult,'rfbbequiv.data')
            setrfdata(ckt,data);
            data=get(ckt,'AnalyzedResult');
        end
        set(ckt,'Block',datasource,'IntpType',interp,...
        'NetworkData',netdata);
        restore(ckt);

    case 'z-params-passive-network'
        if undefparam1({'NetParamData','NetParamFreq'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        interp=get_param(block,'InterpMethod');
        type='Z_PARAMETERS';
        newNetData=MaskWSValues.NetParamData;
        newFreq=MaskWSValues.NetParamFreq;
        newFreq=checkvector(newFreq);
        if~isa(ckt,'rfckt.passive')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.passive('File','');
        end
        netdata=rfdata.network;
        set(netdata,'Block',datasource,'Type',type,'Data',newNetData,...
        'Freq',newFreq);
        if~isa(ckt.AnalyzedResult,'rfbbequiv.data')
            setrfdata(ckt,data);
            data=get(ckt,'AnalyzedResult');
        end
        set(ckt,'Block',datasource,'IntpType',interp,...
        'NetworkData',netdata);
        restore(ckt);

    case 'general-passive-network'
        [hasundef,firstundef]=undefparam1({'RFDATA'},...
        idxMaskNames,MaskWSValues,allEn);
        if hasundef
            if~ismodelstopped
                throwundef(allPrompts{firstundef});
            else
                rfblksflagnoplot(datasource,Udata);
                return
            end
        end
        if~isfield(Udata,'RFDATAObj')||~isa(Udata.RFDATAObj,'rfdata.data')
            Udata.RFDATAObj=rfdata.data;
        end
        set_param(block,'UserData',Udata);
        Udata=get_param(block,'UserData');
        refsource=get_param(block,'DataSource');
        switch refsource
        case 'RFDATA object'
            newdata=MaskWSValues.RFDATA;
        case 'Data file'
            tempfile=get_param(block,'File');
            read(Udata.RFDATAObj,tempfile);
            newdata=Udata.RFDATAObj;
        end
        interp=get_param(block,'InterpMethod');
        if~isa(ckt,'rfckt.passive')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.passive('File','');
        end
        set(ckt,'Block',datasource,'IntpType',interp);


        set(ckt,'CopyPropertyObj',false)
        setrfdata(ckt,data);

        if isa(newdata,'rfdata.data')&&hasreference(newdata)
            local_setref(data,newdata.Reference);

        elseif isa(newdata,'rfdata.data')
            tempnet=rfdata.network('Type','S-Parameters','Freq',...
            newdata.Freq,'Data',newdata.S_Parameters,...
            'Z0',newdata.Z0);
            setreference(data,rfdata.reference('NetworkData',tempnet));

        elseif isa(newdata,'rfdata.reference')||...
            isa(newdata,'rfdata.multireference')
            local_setref(data,newdata);

        elseif isa(newdata,'rfdata.network')
            setreference(data,rfdata.reference('NetworkData',newdata));

        else
            error(message('rfblks:createrfcktfromblk:NotRightData',...
            datasource));
        end

        if haspowerreference(data)
            error(message('rfblks:createrfcktfromblk:PowerDataNotNeeded'));
        elseif hasip3reference(data)
            error(message('rfblks:createrfcktfromblk:IP3DataNotNeeded',...
            datasource));
        elseif hasnoisereference(data)
            error(message('rfblks:createrfcktfromblk:NoiseDataNotNeeded',...
            datasource));
        elseif hasnfreference(data)
            error(message('rfblks:createrfcktfromblk:NFDataNotNeeded',...
            datasource));
        end
        restore(ckt);

    case 'general-circuit-element'
        if undefparam1({'Ckt'},idxMaskNames,MaskWSValues,allEn)&&...
ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        if~isa(MaskWSValues.Ckt,'rfckt.rfckt')||...
            ~isvalid(MaskWSValues.Ckt)
            error(message('rfblks:createrfcktfromblk:NotAnRFCKTObject',...
            datasource));
        end
        ckts=copyckt(MaskWSValues.Ckt);
        if~isa(ckt,'rfckt.cascade')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.cascade;
        end
        set(ckt,'Block',datasource,'Ckts',ckts);

    case 's-params-amplifier'
        if undefparam1({'NetParamData','NetParamFreq','Z0','IIP3','OIP3'...
            ,'P1dB','NF','FMIN','GammaOpt','RN','NFactor','NTemp'...
            ,'PSat'},idxMaskNames,MaskWSValues,allEn)&&...
ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        [ckt,Udata,data]=createsimpleactive(datasource,ckt,...
        Udata,data,MaskWSValues,'amp','S_PARAMETERS');

    case 'y-params-amplifier'
        if undefparam1({'NetParamData','NetParamFreq','IIP3','OIP3','P1dB'...
            ,'NF','FMIN','GammaOpt','RN','NFactor','NTemp','PSat'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        [ckt,Udata,data]=createsimpleactive(datasource,ckt,...
        Udata,data,MaskWSValues,'amp','Y_PARAMETERS');

    case 'z-params-amplifier'
        if undefparam1({'NetParamData','NetParamFreq','IIP3','OIP3','P1dB'...
            ,'NF','FMIN','GammaOpt','RN','NFactor','NTemp','PSat'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        [ckt,Udata,data]=createsimpleactive(datasource,ckt,...
        Udata,data,MaskWSValues,'amp','Z_PARAMETERS');

    case 'general-amplifier'
        [hasundef,firstundef]=undefparam1({'RFDATA','IIP3','OIP3'...
        ,'P1dB','NF','FMIN','GammaOpt','RN','NFactor','NTemp','PSat'},...
        idxMaskNames,MaskWSValues,allEn);
        if hasundef
            if~ismodelstopped
                throwundef(allPrompts{firstundef});
            else
                rfblksflagnoplot(datasource,Udata);
                return
            end
        end
        [ckt,Udata,data]=creategeneralactive(datasource,ckt,...
        Udata,data,MaskWSValues,allEn,allPrompts,'amp');

    case 's-params-mixer'
        if undefparam1({'NetParamData','NetParamFreq','Z0','IIP3','OIP3'...
            ,'P1dB','NF','FMIN','GammaOpt','RN','NFactor','NTemp'...
            ,'PSat','FLO','FreqOffset','PhaseNoiseLevel'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        [ckt,Udata,data]=createsimpleactive(datasource,ckt,...
        Udata,data,MaskWSValues,'mixer','S_PARAMETERS');

    case 'y-params-mixer'
        if undefparam1({'NetParamData','NetParamFreq','IIP3','OIP3','P1dB'...
            ,'NF','FMIN','GammaOpt','RN','NFactor','NTemp','PSat','FLO'...
            ,'FreqOffset','PhaseNoiseLevel'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        [ckt,Udata,data]=createsimpleactive(datasource,ckt,...
        Udata,data,MaskWSValues,'mixer','Y_PARAMETERS');

    case 'z-params-mixer'
        if undefparam1({'NetParamData','NetParamFreq','IIP3','OIP3','P1dB'...
            ,'NF','FMIN','GammaOpt','RN','NFactor','NTemp','PSat','FLO'...
            ,'FreqOffset','PhaseNoiseLevel'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        [ckt,Udata,data]=createsimpleactive(datasource,ckt,...
        Udata,data,MaskWSValues,'mixer','Z_PARAMETERS');

    case 'general-mixer'
        [hasundef,firstundef]=undefparam1({'RFDATA','IIP3','OIP3','P1dB'...
        ,'NF','FMIN','GammaOpt','RN','NFactor','NTemp','PSat','FLO'...
        ,'FreqOffset','PhaseNoiseLevel'},...
        idxMaskNames,MaskWSValues,allEn);
        if hasundef
            if~ismodelstopped
                throwundef(allPrompts{firstundef});
            else
                rfblksflagnoplot(datasource,Udata);
                return
            end
        end
        [ckt,Udata,data]=creategeneralactive(datasource,ckt,...
        Udata,data,MaskWSValues,allEn,allPrompts,'mixer');

    case 'txline'
        if undefparam1({'Z0','PV','Loss','ParamFreq','LineLength'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        z0=MaskWSValues.Z0;
        pv=MaskWSValues.PV;
        loss=MaskWSValues.Loss;
        freq=MaskWSValues.ParamFreq;
        interp=get_param(block,'InterpMethod');
        l=MaskWSValues.LineLength;
        if~isa(ckt,'rfckt.txline')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.txline;
        end
        set(ckt,'Block',datasource,'Z0',z0,'PV',pv,'Loss',loss,...
        'Freq',freq,'IntpType',interp,'LineLength',l);
        termination=MaskWSValues.Termination;
        switch deblank(MaskWSValues.StubMode)
        case 'Shunt'
            set(ckt,'StubMode','Shunt','Termination',termination);
        case 'Series'
            set(ckt,'StubMode','Series','Termination',termination);
        otherwise
            set(ckt,'StubMode','NotAStub','Termination','NotApplicable');
        end

    case 'rlcgline'
        if undefparam1({'R','L','C','G','ParamFreq','LineLength'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        r=MaskWSValues.R;
        L=MaskWSValues.L;
        c=MaskWSValues.C;
        g=MaskWSValues.G;
        freq=MaskWSValues.ParamFreq;
        interp=get_param(block,'InterpMethod');
        l=MaskWSValues.LineLength;
        if~isa(ckt,'rfckt.rlcgline')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.rlcgline;
        end
        set(ckt,'Block',datasource,'R',r,'L',L,'C',c,'G',g,...
        'Freq',freq,'IntpType',interp,'LineLength',l);
        termination=MaskWSValues.Termination;
        switch deblank(MaskWSValues.StubMode)
        case 'Shunt'
            set(ckt,'StubMode','Shunt','Termination',termination);
        case 'Series'
            set(ckt,'StubMode','Series','Termination',termination);
        otherwise
            set(ckt,'StubMode','NotAStub','Termination','NotApplicable');
        end

    case 'twowire'
        if undefparam1({'Radius','Separation','MuR','EpsilonR','SigmaCond'...
            ,'SigmaDiel','LineLength'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        r=MaskWSValues.Radius;
        d=MaskWSValues.Separation;
        mu=MaskWSValues.MuR;
        e=MaskWSValues.EpsilonR;
        sigmacond=MaskWSValues.SigmaCond;
        sigmadiel=MaskWSValues.SigmaDiel;
        losstangent=MaskWSValues.LossTangent;
        issuewarningmsg=MaskWSValues.IssueWarningforNonzeroSigmaDiel;
        l=MaskWSValues.LineLength;
        if~isa(ckt,'rfckt.twowire')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.twowire;
        end
        set(ckt,'IssueWarningforNonzeroSigmaDiel',issuewarningmsg);
        set(ckt,'Block',datasource,'Radius',r,'Separation',d,...
        'MuR',mu,'EpsilonR',e,'SigmaCond',sigmacond,...
        'SigmaDiel',sigmadiel,'LossTangent',losstangent,...
        'LineLength',l);
        termination=MaskWSValues.Termination;
        switch deblank(MaskWSValues.StubMode)
        case 'Shunt'
            set(ckt,'StubMode','Shunt','Termination',termination);
        case 'Series'
            set(ckt,'StubMode','Series','Termination',termination);
        otherwise
            set(ckt,'StubMode','NotAStub','Termination','NotApplicable');
        end

    case 'coaxial'
        if undefparam1({'InnerRadius','OuterRadius','MuR','EpsilonR'...
            ,'SigmaCond','SigmaDiel','LineLength'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        a=MaskWSValues.InnerRadius;
        b=MaskWSValues.OuterRadius;
        mu=MaskWSValues.MuR;
        e=MaskWSValues.EpsilonR;
        sigmacond=MaskWSValues.SigmaCond;
        sigmadiel=MaskWSValues.SigmaDiel;
        losstangent=MaskWSValues.LossTangent;
        issuewarningmsg=MaskWSValues.IssueWarningforNonzeroSigmaDiel;
        l=MaskWSValues.LineLength;
        if~isa(ckt,'rfckt.coaxial')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.coaxial;
        end
        set(ckt,'IssueWarningforNonzeroSigmaDiel',issuewarningmsg);
        set(ckt,'Block',datasource,'InnerRadius',a,'OuterRadius',b,...
        'MuR',mu,'EpsilonR',e,'SigmaCond',sigmacond,...
        'SigmaDiel',sigmadiel,'LossTangent',losstangent,...
        'LineLength',l);
        termination=MaskWSValues.Termination;
        switch deblank(MaskWSValues.StubMode)
        case 'Shunt'
            set(ckt,'StubMode','Shunt','Termination',termination);
        case 'Series'
            set(ckt,'StubMode','Series','Termination',termination);
        otherwise
            set(ckt,'StubMode','NotAStub','Termination','NotApplicable');
        end

    case 'parallelplate'
        if undefparam1({'Width','Separation','MuR','EpsilonR','SigmaCond'...
            ,'SigmaDiel','LineLength'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        w=MaskWSValues.Width;
        d=MaskWSValues.Separation;
        mu=MaskWSValues.MuR;
        e=MaskWSValues.EpsilonR;
        sigmacond=MaskWSValues.SigmaCond;
        sigmadiel=MaskWSValues.SigmaDiel;
        losstangent=MaskWSValues.LossTangent;
        issuewarningmsg=MaskWSValues.IssueWarningforNonzeroSigmaDiel;
        l=MaskWSValues.LineLength;
        if~isa(ckt,'rfckt.parallelplate')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.parallelplate;
        end
        set(ckt,'IssueWarningforNonzeroSigmaDiel',issuewarningmsg);
        set(ckt,'Block',datasource,'Width',w,'Separation',d,...
        'MuR',mu,'EpsilonR',e,'SigmaCond',sigmacond,...
        'SigmaDiel',sigmadiel,'LossTangent',losstangent,...
        'LineLength',l);
        termination=MaskWSValues.Termination;
        switch deblank(MaskWSValues.StubMode)
        case 'Shunt'
            set(ckt,'StubMode','Shunt','Termination',termination);
        case 'Series'
            set(ckt,'StubMode','Series','Termination',termination);
        otherwise
            set(ckt,'StubMode','NotAStub','Termination','NotApplicable');
        end

    case 'microstrip'
        if undefparam1({'Width','Height','Thickness','EpsilonR','SigmaCond'...
            ,'LossTangent','LineLength'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        w=MaskWSValues.Width;
        h=MaskWSValues.Height;
        t=MaskWSValues.Thickness;
        e=MaskWSValues.EpsilonR;
        sigmacond=MaskWSValues.SigmaCond;
        losstan=MaskWSValues.LossTangent;
        l=MaskWSValues.LineLength;
        if~isa(ckt,'rfckt.microstrip')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.microstrip;
        end
        set(ckt,'Block',datasource,'Width',w,'Height',h,...
        'Thickness',t,'EpsilonR',e,'SigmaCond',sigmacond,...
        'LossTangent',losstan,'LineLength',l);
        termination=MaskWSValues.Termination;
        switch deblank(MaskWSValues.StubMode)
        case 'Shunt'
            set(ckt,'StubMode','Shunt','Termination',termination);
        case 'Series'
            set(ckt,'StubMode','Series','Termination',termination);
        otherwise
            set(ckt,'StubMode','NotAStub','Termination','NotApplicable');
        end

    case 'cpw'
        if undefparam1({'ConductorWidth','SlotWidth','Height','Thickness'...
            ,'EpsilonR','SigmaCond','LossTangent','LineLength'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        w=MaskWSValues.ConductorWidth;
        s=MaskWSValues.SlotWidth;
        h=MaskWSValues.Height;
        t=MaskWSValues.Thickness;
        e=MaskWSValues.EpsilonR;
        sigmacond=MaskWSValues.SigmaCond;
        losstan=MaskWSValues.LossTangent;
        l=MaskWSValues.LineLength;
        if~isa(ckt,'rfckt.cpw')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.cpw;
        end
        set(ckt,'Block',datasource,'ConductorWidth',w,'SlotWidth',s,...
        'Height',h,'Thickness',t,'EpsilonR',e,...
        'SigmaCond',sigmacond,'LossTangent',losstan,'LineLength',l);
        termination=MaskWSValues.Termination;
        switch deblank(MaskWSValues.StubMode)
        case 'Shunt'
            set(ckt,'StubMode','Shunt','Termination',termination);
        case 'Series'
            set(ckt,'StubMode','Series','Termination',termination);
        otherwise
            set(ckt,'StubMode','NotAStub','Termination','NotApplicable');
        end

    case 'lclowpasstee'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lclowpasstee')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lclowpasstee;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'lclowpasspi'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lclowpasspi')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lclowpasspi;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'lchighpasstee'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lchighpasstee')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lchighpasstee;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'lchighpasspi'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lchighpasspi')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lchighpasspi;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'lcbandpasstee'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lcbandpasstee')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lcbandpasstee;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'lcbandpasspi'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lcbandpasspi')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lcbandpasspi;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'lcbandstoptee'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lcbandstoptee')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lcbandstoptee;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'lcbandstoppi'
        if undefparam1({'L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.lcbandstoppi')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.lcbandstoppi;
        end
        set(ckt,'Block',datasource,'L',l,'C',c);

    case 'seriesrlc'
        if undefparam1({'R','L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        r=MaskWSValues.R;
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.seriesrlc')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.seriesrlc;
        end
        set(ckt,'Block',datasource,'R',r,'L',l,'C',c);

    case 'shuntrlc'
        if undefparam1({'R','L','C'},...
            idxMaskNames,MaskWSValues,allEn)&&ismodelstopped
            rfblksflagnoplot(datasource,Udata);
            return
        end
        r=MaskWSValues.R;
        l=MaskWSValues.L;
        c=MaskWSValues.C;
        if~isa(ckt,'rfckt.shuntrlc')||~isvalid(ckt)
            if isa(ckt,'rfbase.rfbase')
                delete(ckt);
            end
            ckt=rfckt.shuntrlc;
        end
        set(ckt,'Block',datasource,'R',r,'L',l,'C',c);

    otherwise
        error(message('rfblks:createrfcktfromblk:UnrecognizedBlock',...
        datasource));

    end

    dontcopypropertyobj(ckt);
    set(data,'CopyPropertyObj',false,'Block',datasource);
    set(data,'Block',datasource);
    if isa(data.Reference,'rfdata.reference')
        set(data.Reference,'CopyPropertyObj',false);
    end
    checkproperty(ckt);
    flags=setflagindexes(ckt);
    updateflag(ckt,flags.indexOfThePropertyIsChecked,1,...
    flags.MaxNumberOfFlags);

    if~isa(ckt.AnalyzedResult,'rfbbequiv.data')
        setrfdata(ckt,data);
    end


    Udata.Ckt=ckt;
    Udata.Plot=true;
    set_param(block,'UserData',Udata);


    function output=checkvector(input)

        output=input;


        if isvector(input)
            vectorpoint=size(input);
            d1=vectorpoint(1);
            if(d1==1)
                output=input';
            end
        end


        function ckts=copyckt(original_ckts)
            ckts={};

            if isa(original_ckts,'cell')
                nckts=length(original_ckts);
                for j=1:nckts
                    original_ckt=original_ckts{j};
                    if isa(original_ckt,'rfckt.rfckt')&&isvalid(original_ckt)
                        if isa(original_ckt,'rfckt.datafile')&&isnonlinear(original_ckt)
                            ckts{j}=rfckt.amplifier('File',original_ckt.File);
                        else
                            ckts{j}=copy(original_ckt);
                        end
                        return
                    end
                end
            elseif isa(original_ckts,'rfckt.rfckt')&&isvalid(original_ckts)
                original_ckt=original_ckts;
                if isa(original_ckt,'rfckt.datafile')&&isnonlinear(original_ckt)
                    ckts{1}=rfckt.amplifier('File',original_ckt.File);
                else
                    ckts{1}=copy(original_ckt);
                end
                return
            end
            error(message('rfblks:createrfcktfromblk:NotAnRFCKTObject',...
            original_ckts.Name));


            function dontcopypropertyobj(ckt)
                if isa(ckt,'rfckt.rfckt')&&isvalid(ckt)
                    set(ckt,'CopyPropertyObj',false);
                    if isa(ckt.AnalyzedResult,'rfdata.data')
                        set(ckt.AnalyzedResult,'CopyPropertyObj',false);
                        if isa(ckt.AnalyzedResult.Reference,'rfdata.reference')
                            set(ckt.AnalyzedResult.Reference,'CopyPropertyObj',false);
                        end
                    end
                    if isa(ckt,'rfckt.network')||isa(ckt,'rfckt.ladderfilter')
                        ckts=get(ckt,'CKTS');
                        nckts=length(ckts);
                        for j=1:nckts
                            dontcopypropertyobj(ckts{j});
                        end
                    end
                end


                function str=conditions2str(conditions)


                    temp=strcat(conditions,'!');
                    str=strcat(temp{:});


                    function conditions=str2conditions(str)


                        loc=strfind(str,'!');
                        conditions=cell(numel(loc),1);
                        sp=1;
                        for ii=1:numel(loc)
                            conditions{ii}=str(sp:loc(ii)-1);
                            sp=loc(ii)+1;
                        end


                        function y=nfactor2nf(x)
                            if~isempty(x)&&(~isnumeric(x)||~isvector(x)||~isreal(x)||min(x)<1)
                                error(message('rfblks:createrfcktfromblk:InvalidNoiseFactor'));
                            end
                            y=10*log10(x);


                            function y=ntemp2nf(x)
                                if~isempty(x)&&(~isnumeric(x)||~isvector(x)||~isreal(x)||min(x)<0)
                                    error(message('rfblks:createrfcktfromblk:InvalidNoiseTemperature'));
                                end
                                y=10*log10(1+x/290);


                                function[isundef,undefvar]=...
                                    undefparam1(vars,idxMaskNames,MaskWSValues,En)














                                    for varName=vars
                                        if strcmpi('on',En(idxMaskNames.(varName{1})))
                                            if isempty(MaskWSValues.(varName{1}))
                                                isundef=true;
                                                undefvar=varName;
                                                return
                                            end
                                        end
                                    end

                                    isundef=false;
                                    undefvar=NaN;


                                    function throwundef(myprompt)

                                        error(message('rfblks:createrfcktfromblk:UndefinedParam',...
                                        strtok(myprompt,':')));


                                        function result=ismodelstopped
                                            result=false;
                                            if strcmpi(get_param(bdroot,'SimulationStatus'),'stopped')
                                                result=true;
                                            end


                                            function[ckt,Udata,data]=createsimpleactive(block,ckt,Udata,...
                                                data,MaskWSValues,ckttype,nettype)


                                                interp=get_param(block,'InterpMethod');
                                                type=nettype;
                                                newNetData=MaskWSValues.NetParamData;
                                                newFreq=MaskWSValues.NetParamFreq;
                                                newFreq=checkvector(newFreq);
                                                if strncmpi(type,'S',1)
                                                    newZ0=MaskWSValues.Z0;
                                                else
                                                    newZ0=50;
                                                end


                                                if strcmpi(ckttype,'amp')
                                                    if~isa(ckt,'rfckt.amplifier')||~isvalid(ckt)
                                                        if isa(ckt,'rfbase.rfbase')
                                                            delete(ckt);
                                                        end
                                                        ckt=rfckt.amplifier('File','');
                                                    end
                                                    set(ckt,'Block',block)
                                                else
                                                    if~isa(ckt,'rfckt.mixer')||~isvalid(ckt)
                                                        if isa(ckt,'rfbase.rfbase')
                                                            delete(ckt);
                                                        end
                                                        ckt=rfckt.mixer('File','');
                                                    end
                                                    mixtype=get_param(block,'MixerType');
                                                    flo=MaskWSValues.FLO;
                                                    offset=checkvector(MaskWSValues.FreqOffset);
                                                    pnoise=checkvector(MaskWSValues.PhaseNoiseLevel);
                                                    set(ckt,'Block',block,'MixerSpurData',[],'MixerType',mixtype,...
                                                    'FLO',flo,'FreqOffset',offset,'PhaseNoiseLevel',pnoise)
                                                end

                                                if~isa(ckt.AnalyzedResult,'rfbbequiv.data')
                                                    set(ckt,'CopyPropertyObj',false);
                                                    setrfdata(ckt,data);
                                                    data=get(ckt,'AnalyzedResult');
                                                end


                                                netdata=rfdata.network;
                                                set(netdata,'Block',block,'Type',type,'Data',newNetData,...
                                                'Freq',newFreq,'Z0',newZ0);
                                                set(ckt,'IntpType',interp,'NetworkData',netdata);


                                                set(ckt,'IIP3',inf,'OIP3',inf,'PowerData',[],'IP3Data',[]);
                                                ckt=getnonlineardata(block,ckt,MaskWSValues);


                                                ckt=getnoisedata(block,ckt,MaskWSValues);

                                                restore(ckt);


                                                function[ckt,Udata,data]=creategeneralactive(block,ckt,...
                                                    Udata,data,MaskWSValues,allEn,allPrompts,ckttype)


                                                    if~isfield(Udata,'RFDATAObj')||~isa(Udata.RFDATAObj,'rfdata.data')
                                                        Udata.RFDATAObj=rfdata.data;
                                                    end
                                                    set_param(block,'UserData',Udata);
                                                    Udata=get_param(block,'UserData');
                                                    refsource=get_param(block,'DataSource');
                                                    switch refsource
                                                    case 'RFDATA object'
                                                        newdata=MaskWSValues.RFDATA;
                                                    case 'Data file'
                                                        tempfile=get_param(block,'File');
                                                        read(Udata.RFDATAObj,tempfile);
                                                        newdata=Udata.RFDATAObj;
                                                    end

                                                    interp=get_param(block,'InterpMethod');
                                                    if strcmpi(ckttype,'amp')
                                                        if~isa(ckt,'rfckt.amplifier')||~isvalid(ckt)
                                                            if isa(ckt,'rfbase.rfbase')
                                                                delete(ckt);
                                                            end
                                                            ckt=rfckt.amplifier('File','');
                                                        end
                                                        set(ckt,'Block',block,'IntpType',interp);
                                                    else
                                                        if~isa(ckt,'rfckt.mixer')||~isvalid(ckt)
                                                            if isa(ckt,'rfbase.rfbase')
                                                                delete(ckt);
                                                            end
                                                            ckt=rfckt.mixer('File','');
                                                        end
                                                        mixtype=get_param(block,'MixerType');
                                                        flo=MaskWSValues.FLO;
                                                        set(ckt,'Block',block,'IntpType',interp,'MixerType',mixtype,...
                                                        'FLO',flo);
                                                    end


                                                    set(ckt,'CopyPropertyObj',false)
                                                    setrfdata(ckt,data);



                                                    if isa(newdata,'rfdata.data')&&hasreference(newdata)
                                                        local_setref(data,newdata.Reference);

                                                    elseif isa(newdata,'rfdata.data')

                                                        tempnet=rfdata.network('Type','S-Parameters','Freq',...
                                                        newdata.Freq,'Data',newdata.S_Parameters,'Z0',newdata.Z0);
                                                        setreference(data,rfdata.reference('NetworkData',tempnet));

                                                    elseif isa(newdata,'rfdata.reference')||...
                                                        isa(newdata,'rfdata.multireference')
                                                        local_setref(data,newdata);

                                                    elseif isa(newdata,'rfdata.network')
                                                        setreference(data,rfdata.reference('NetworkData',newdata));

                                                    else
                                                        error(message('rfblks:createrfcktfromblk:NotRightData',block));
                                                    end


                                                    if isa(ckt.AnalyzedResult,'rfdata.data')&&...
                                                        hasreference(ckt.AnalyzedResult)
                                                        Udata.Filename=ckt.AnalyzedResult.Reference.Filename;
                                                        Udata.Date=ckt.AnalyzedResult.Reference.Date;
                                                    end

                                                    if hasmultireference(ckt.AnalyzedResult)

                                                        if all(isfield(Udata,{'ConditionNames','ConditionValues'}))&&...
                                                            ~isempty(Udata.ConditionNames)&&...
                                                            ~isempty(Udata.ConditionValues)
                                                            ConditionNames=Udata.ConditionNames;
                                                            str_ConditionNames=conditions2str(Udata.ConditionNames);
                                                            ConditionValues=Udata.ConditionValues;
                                                            str_ConditionValues=conditions2str(Udata.ConditionValues);

                                                            set_param(block,'ConditionNames',str_ConditionNames,...
                                                            'ConditionValues',str_ConditionValues);
                                                        elseif~isempty(strfind(MaskWSValues.ConditionNames,'!'))&&...
                                                            ~isempty(strfind(MaskWSValues.ConditionValues,'!'))
                                                            ConditionNames=str2conditions(MaskWSValues.ConditionNames);
                                                            ConditionValues=str2conditions(MaskWSValues.ConditionValues);
                                                        else
                                                            ConditionNames={};
                                                            ConditionValues={};
                                                        end

                                                        if~isempty(ConditionNames)&&~isempty(ConditionValues)

                                                            numericvars=getnumericvars(ckt.AnalyzedResult.Reference);
                                                            criteria=cell(1,2*numel(ConditionNames));
                                                            for ii=1:numel(ConditionNames)
                                                                criteria{2*ii-1}=ConditionNames{ii};
                                                                if any(strcmpi(numericvars,ConditionNames{ii}))

                                                                    criteria{2*ii}=str2num(ConditionValues{ii});
                                                                else
                                                                    criteria{2*ii}=ConditionValues{ii};
                                                                end
                                                            end

                                                            if~isempty(criteria)
                                                                setop(ckt.AnalyzedResult,criteria{:});
                                                            end
                                                        end
                                                    end

                                                    idxMaskNames=rfblksgetblockmaskparamsindex(block);
                                                    [hasundef,firstundef]=undefparam1({'IIP3','OIP3','P1dB','NF','FMIN'...
                                                    ,'GammaOpt','RN','NFactor','NTemp','PSat'},...
                                                    idxMaskNames,MaskWSValues,allEn);
                                                    if hasundef&&~ismodelstopped
                                                        throwundef(allPrompts{firstundef});
                                                    end


                                                    ckt=getnonlineardata(block,ckt,MaskWSValues);


                                                    ckt=getnoisedata(block,ckt,MaskWSValues);


                                                    if strcmpi(ckttype,'mixer')
                                                        offset=checkvector(MaskWSValues.FreqOffset);
                                                        pnoise=checkvector(MaskWSValues.PhaseNoiseLevel);
                                                        set(ckt,'FreqOffset',offset,'PhaseNoiseLevel',pnoise);
                                                    end
                                                    restore(ckt);


                                                    if isa(ckt.AnalyzedResult,'rfdata.data')&&...
                                                        hasmultireference(ckt.AnalyzedResult)&&...
                                                        ckt.AnalyzedResult.Reference.Selection
                                                        Udata.RefSel=ckt.AnalyzedResult.Reference.Selection;
                                                    else
                                                        Udata.RefSel=0;
                                                    end


                                                    function local_setref(mydata,myref)

                                                        if hasreference(mydata)&&...
                                                            strcmp(mydata.Reference.Filename,myref.Filename)&&...
                                                            strcmp(mydata.Reference.Date,myref.Date)&&...
                                                            ~isempty(myref.Filename)&&~isempty(myref.Date)
                                                            return
                                                        end
                                                        setreference(mydata,copy(myref));


                                                        function ckt=getnonlineardata(block,ckt,MaskWSValues)

                                                            iip3=inf;
                                                            oip3=inf;
                                                            p1db=inf;
                                                            psat=inf;
                                                            gcsat=1;
                                                            idxMaskNames=rfblksgetblockmaskparamsindex(block);
                                                            En=get_param(block,'MaskEnables');
                                                            if~(haspowerreference(ckt.AnalyzedResult)||...
                                                                hasip3reference(ckt.AnalyzedResult)||...
                                                                hasp2dreference(ckt.AnalyzedResult))
                                                                if strncmpi(En{idxMaskNames.IP3Type},'on',2)
                                                                    if strncmpi(En{idxMaskNames.OIP3},'on',2)
                                                                        oip3=MaskWSValues.OIP3;
                                                                    elseif strncmpi(En{idxMaskNames.IIP3},'on',2)
                                                                        iip3=MaskWSValues.IIP3;
                                                                    end
                                                                end
                                                                if strncmpi(En{idxMaskNames.P1dB},'on',2)
                                                                    p1db=MaskWSValues.P1dB;
                                                                end
                                                                if strncmpi(En{idxMaskNames.PSat},'on',2)
                                                                    psat=MaskWSValues.PSat;
                                                                end
                                                                if strncmpi(En{idxMaskNames.GCSat},'on',2)
                                                                    gcsat=MaskWSValues.GCSat;
                                                                end
                                                                nonlinearfreq=MaskWSValues.NonlinearDataFreq;
                                                                nfreq=length(nonlinearfreq);
                                                                oip3=checknonlinearandnoisedata(oip3,'OIP3',nfreq,true);
                                                                iip3=checknonlinearandnoisedata(iip3,'IIP3',nfreq,true);
                                                                p1db=checknonlinearandnoisedata(p1db,...
                                                                '1dB gain compression power',nfreq,true);
                                                                psat=checknonlinearandnoisedata(psat,'Output saturation power',...
                                                                nfreq,true);
                                                                gcsat=checknonlinearandnoisedata(gcsat,...
                                                                'Gain compression at saturation',nfreq,false);
                                                                tempref=getreference(ckt.AnalyzedResult);
                                                                set(tempref,'OneDBC',0.001*10.^(p1db/10),...
                                                                'PS',0.001*10.^(psat/10),'IIP3',0.001*10.^(iip3/10),...
                                                                'OIP3',0.001*10.^(oip3/10),'GCS',10.^(gcsat/10),...
                                                                'NonlinearDataFreq',nonlinearfreq);
                                                            end

                                                            function ckt=getnoisedata(block,ckt,MaskWSValues)

                                                                nfdata=ckt.NFData;
                                                                noisedata=ckt.NoiseData;
                                                                En=get_param(block,'MaskEnables');
                                                                idxMaskNames=rfblksgetblockmaskparamsindex(block);


                                                                Noise_From_File=false;

                                                                if isfield(MaskWSValues,'File')&&...
                                                                    (hasnoisereference(ckt.AnalyzedResult)||...
                                                                    hasnfreference(ckt.AnalyzedResult))
                                                                    Noise_From_File=true;
                                                                end
                                                                if~Noise_From_File&&strncmpi(En{idxMaskNames.NoiseDataFreq},'on',2)
                                                                    noisefreq=MaskWSValues.NoiseDataFreq;
                                                                    nfreq=length(noisefreq);
                                                                    noisedefinedby=get_param(block,'NoiseDefinedBy');
                                                                    switch noisedefinedby
                                                                    case 'Noise figure'
                                                                        noisedata=[];
                                                                        if isa(MaskWSValues.NF,'rfdata.nf')
                                                                            nfdata=MaskWSValues.NF;
                                                                        else
                                                                            nf=checknonlinearandnoisedata(MaskWSValues.NF,...
                                                                            'Noise figure',nfreq,false);
                                                                            if isa(nfdata,'rfdata.nf')
                                                                                set(nfdata,'Block',block,'Freq',noisefreq,...
                                                                                'Data',nf);
                                                                            else
                                                                                nfdata=rfdata.nf('Block',block,...
                                                                                'Freq',noisefreq,'Data',nf);
                                                                            end
                                                                        end
                                                                    case 'Spot noise data'
                                                                        nfdata=[];
                                                                        fmin=checknonlinearandnoisedata(MaskWSValues.FMIN,...
                                                                        'Minimum noise figure',nfreq,false);
                                                                        gammaopt=checknonlinearandnoisedata(...
                                                                        MaskWSValues.GammaOpt,...
                                                                        'Optimal reflection coefficient',nfreq,false);
                                                                        rn=checknonlinearandnoisedata(MaskWSValues.RN,...
                                                                        'Equivalent normalized noise resistance',nfreq,false);
                                                                        noisedata=rfdata.noise('Block',block,'Freq',noisefreq,...
                                                                        'FMIN',fmin,'GammaOpt',gammaopt,'RN',rn);
                                                                    case 'Noise factor'
                                                                        noisedata=[];
                                                                        nfactor=checknonlinearandnoisedata(MaskWSValues.NFactor,...
                                                                        'Noise factor',nfreq,false);
                                                                        if isa(nfdata,'rfdata.nf')
                                                                            set(nfdata,'Block',block,'Freq',noisefreq,...
                                                                            'Data',nfactor2nf(nfactor));
                                                                        else
                                                                            nfdata=rfdata.nf('Block',block,'Freq',noisefreq,...
                                                                            'Data',nfactor2nf(nfactor));
                                                                        end
                                                                    case 'Noise temperature'
                                                                        noisedata=[];
                                                                        ntemp=checknonlinearandnoisedata(MaskWSValues.NTemp,...
                                                                        'Noise temperature',nfreq,false);
                                                                        if isa(nfdata,'rfdata.nf')
                                                                            set(nfdata,'Block',block,'Freq',noisefreq,...
                                                                            'Data',ntemp2nf(ntemp));
                                                                        else
                                                                            nfdata=rfdata.nf('Block',block,'Freq',noisefreq,...
                                                                            'Data',ntemp2nf(ntemp));
                                                                        end
                                                                    end
                                                                end

                                                                set(ckt,'NoiseData',noisedata,'NFData',nfdata,'NF',0);


                                                                function inputdata=checknonlinearandnoisedata(inputdata,...
                                                                    datadescription,nfreq,allow_infinite)

                                                                    ndata=length(inputdata);
                                                                    if(ndata~=1)&&(ndata~=nfreq)
                                                                        error(message('rfblks:createrfcktfromblk:WrongDataInput',...
                                                                        datadescription));
                                                                    end

                                                                    if(~allow_infinite&&any(isinf(inputdata))||any(isnan(inputdata)))
                                                                        error(message('rfblks:createrfcktfromblk:DataNotFiniteVector',...
                                                                        datadescription));
                                                                    end

                                                                    if(ndata==1)&&(nfreq>1)
                                                                        inputdata(1:nfreq)=inputdata;
                                                                    end