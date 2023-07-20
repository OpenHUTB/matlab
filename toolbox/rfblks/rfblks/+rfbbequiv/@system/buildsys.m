function h=buildsys(h,originalckts)







    rearranged_ckts={};
    for j=1:length(originalckts)
        originalckt=originalckts{j};
        if isa(originalckt,'rfckt.rfckt')
            rearranged_ckts=processckt(rearranged_ckts,originalckt);
        end
    end


    models=get(h,'Models');
    originalckt=get(h,'OriginalCkt');
    if~isa(originalckt,'rfckt.cascade')
        originalckt=rfckt.cascade('CopyPropertyObj',false);
        data1=rfbbequiv.data('CopyPropertyObj',false);
        setrfdata(originalckt,data1);
        set(h,'OriginalCkt',originalckt);
    end
    flags=setflagindexes(originalckt);
    updateflag(originalckt,flags.indexOfThePropertyIsChecked,1,...
    flags.MaxNumberOfFlags);
    set(originalckt,'Ckts',originalckts);

    rearranged_nckts=length(rearranged_ckts);

    current_index=0;
    nckts=0;
    ckts={};

    for j=1:rearranged_nckts
        ckt=rearranged_ckts{j};
        updatedata(ckt);
        if~ckt.isnonlinear&&~isa(ckt,'rfckt.mixer')
            [nckts,ckts]=add(nckts,ckts,ckt);
        elseif(isa(ckt,'rfckt.passive')&&isempty(ckt.NetworkData))||...
            (isa(ckt,'rfckt.datafile')&&(isempty(ckt.AnalyzedResult)||...
            isempty(ckt.AnalyzedResult.S_Parameters)))

            [current_index,models]=addlinearrfmodel(current_index,...
            models,ckts);


            [current_index,models]=addnonlinearrfmodel(current_index,...
            models,ckt);

            nckts=0;
            ckts={};
        else
            lin_1=getthefirst(ckt);

            [nckts,ckts]=add(nckts,ckts,lin_1);

            [current_index,models]=addlinearrfmodel(current_index,...
            models,ckts);

            [current_index,models]=addnonlinearrfmodel(current_index,...
            models,ckt);

            nckts=0;
            ckts={};
            lin_2=getthesecond(ckt);
            set(lin_2,'EqualToOriginal',false);

            [nckts,ckts]=add(nckts,ckts,lin_2);
        end
    end


    if~isempty(ckts)||isempty(rearranged_ckts)
        [current_index,models]=addlinearrfmodel(current_index,...
        models,ckts);
    end


    for i=1:current_index
        set(models{i},'DeleteCkt',false,'AllPassFilter',false);
    end
    for i=current_index+1:length(models)
        if isa(models{i},'rfbbequiv.nonlinear')
            set(models{i},'Method',0,'InputEffect',1,'OutputGain',1);
        end
        set(models{i},'DeleteCkt',false,'ImpulseResp',1,...
        'AllPassFilter',true);
    end

    if current_index==2
        if isempty(models{1}.RFckt.Ckts)
            set(models{1},'AllPassFilter',true);
        end
    end
    set(h,'Models',models,'nModels',current_index);


    function[num_obj,objects]=add(num_obj,objects,new_obj)

        objects{num_obj+1}=new_obj;
        num_obj=num_obj+1;


        function lin_1=getthefirst(ckt)
            udata=get(ckt,'UserData');
            if isempty(udata)
                set(ckt,'UserData',{rfbbequiv.ampinput(...
                'CopyPropertyObj',false,'OriginalCkt',ckt),...
                rfbbequiv.ampoutput('CopyPropertyObj',false,...
                'OriginalCkt',ckt)});
                udata=get(ckt,'UserData');
            end
            lin_1=udata{1};
            set(lin_1,'OriginalCkt',ckt);

            function lin_2=getthesecond(ckt)
                udata=get(ckt,'UserData');
                if isempty(udata)
                    set(ckt,'UserData',{rfbbequiv.ampinput(...
                    'CopyPropertyObj',false,'OriginalCkt',ckt),...
                    rfbbequiv.ampoutput('CopyPropertyObj',false,...
                    'OriginalCkt',ckt)});
                    udata=get(ckt,'UserData');
                end
                lin_2=udata{2};
                set(lin_2,'OriginalCkt',ckt);


                function rearranged_ckts=processckt(rearranged_ckts,ckt)
                    rearranged_nckts=length(rearranged_ckts);

                    if isa(ckt,'rfckt.cascade')
                        ckts=get(ckt,'Ckts');
                        nckts=length(ckts);
                        if(nckts>0)
                            for j=1:nckts
                                rearranged_ckts=processckt(rearranged_ckts,ckts{j});
                            end
                            return
                        end
                    end
                    rearranged_nckts=rearranged_nckts+1;
                    rearranged_ckts{rearranged_nckts}=ckt;


                    function updatedata(ckt)
                        data=get(ckt,'AnalyzedResult');
                        if~isa(data,'rfbbequiv.data')
                            copiedref=[];
                            netdata=[];
                            powerdata=[];
                            ip3data=[];
                            noisedata=[];
                            nfdata=[];
                            mixerdata=[];
                            if isa(data,'rfdata.data')&&hasreference(data)
                                set(data,'CopyPropertyObj',true);
                                copieddata=copy(data);
                                copiedref=getreference(copieddata);
                                netdata=copiedref.NetworkData;
                                powerdata=copiedref.PowerData;
                                ip3data=copiedref.IP3Data;
                                noisedata=copiedref.NoiseData;
                                nfdata=copiedref.NFData;
                                mixerdata=copiedref.MixerSpurData;
                            end
                            newdata=rfbbequiv.data('CopyPropertyObj',false);
                            setreference(newdata,copiedref);
                            if isa(data,'rfdata.data')
                                set(newdata,'Freq',data.Freq,...
                                'S_Parameters',data.S_Parameters,'NF',data.NF,...
                                'OIP3',data.OIP3,'Z0',data.Z0,'ZS',data.ZS,...
                                'ZL',data.ZL,'IntpType',data.IntpType);
                            end
                            setrfdata(ckt,newdata);
                            if isa(ckt,'rfckt.passive')
                                ckt.NetworkData=netdata;
                            end
                            if isa(ckt,'rfckt.amplifier')
                                ckt.PowerData=powerdata;
                                ckt.IP3Data=ip3data;
                                ckt.NFData=nfdata;
                                ckt.NoiseData=noisedata;
                            end
                            if isa(ckt,'rfckt.mixer')
                                ckt.MixerSpurData=mixerdata;
                            end
                        end


                        function[index,models]=addlinearrfmodel(index,models,ckts)
                            index=index+1;
                            model=[];
                            nmodels=length(models);
                            if index<=nmodels
                                model=models{index};
                            end
                            if~isa(model,'rfbbequiv.linear')
                                ckt=rfckt.cascade('CopyPropertyObj',false);
                                data=rfbbequiv.data('CopyPropertyObj',false);
                                setrfdata(ckt,data);
                                model=rfbbequiv.linear('RFckt',ckt);
                                models{index}=model;
                            end
                            ckt=get(model,'RFckt');
                            if~isa(ckt,'rfckt.cascade')
                                ckt=rfckt.cascade('CopyPropertyObj',false);
                                data=rfbbequiv.data('CopyPropertyObj',false);
                                setrfdata(ckt,data);
                                ckt=get(model,'RFckt');
                            end
                            flags=setflagindexes(ckt);
                            updateflag(ckt,flags.indexOfNoiseOn,0,flags.MaxNumberOfFlags);
                            updateflag(ckt,flags.indexOfDoNonlinearAna,0,flags.MaxNumberOfFlags);
                            updateflag(ckt,flags.indexOfThePropertyIsChecked,1,...
                            flags.MaxNumberOfFlags);
                            set(ckt,'Ckts',ckts);
                            data=get(ckt,'AnalyzedResult');
                            if~isa(data,'rfbbequiv.data')
                                setrfdata(ckt,rfbbequiv.data('CopyPropertyObj',false));
                                data=get(ckt,'AnalyzedResult');
                            end
                            if isempty(ckts)
                                set(data,'S_Parameters',[],'Freq',[]);
                            end

                            if index>2
                                data.Zs=models{index-1}.RFckt.AnalyzedResult.Zl;
                            end

                            function[index,models]=addnonlinearrfmodel(index,models,ckt)
                                index=index+1;
                                model=[];
                                nmodels=length(models);
                                if index<=nmodels
                                    model=models{index};
                                end
                                if~isa(model,'rfbbequiv.nonlinear')
                                    model=rfbbequiv.nonlinear;
                                    models{index}=model;
                                end
                                data=get(ckt,'AnalyzedResult');
                                if~isa(data,'rfbbequiv.data')
                                    setrfdata(ckt,rfbbequiv.data('CopyPropertyObj',false));
                                end
                                set(data,'Zs',data.Z0,'Zl',data.Z0);
                                models{index-1}.RFckt.AnalyzedResult.Zl=data.Zs;
                                set(model,'RFckt',ckt);