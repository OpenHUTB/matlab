function[valData,valDataInv]=getValueStringAllowInv(h,legendData,showAnnotations,tabIdx)



    valData.Name='';
    theValue=legendData.Value;

    if(~isempty(legendData.ComponentSampleTimes))
        if(showAnnotations)
            valData.Name=legendData.ComponentSampleTimes(1).Annotation;
            for compTsIdx=2:length(legendData.ComponentSampleTimes)
                valData.Name=...
                [valData.Name,...
                ',',...
                legendData.ComponentSampleTimes(compTsIdx).Annotation];
            end
        else
            valData.Name=DAStudio.message('Simulink:SampleTime:SampleTimeValueNA');
        end

    elseif(isempty(legendData.Owner))


        if(ischar(theValue))
            valData.Name=theValue;
        elseif(isempty(theValue)||isequal(theValue,[-1,-inf]))
            valData.Name=DAStudio.message('Simulink:SampleTime:SampleTimeValueNA');
        elseif((theValue(2)==0)&&(theValue(1)>=0))
            valData.Name=num2str(theValue(1));
        elseif(isequal(theValue,[inf,inf])||isequal(theValue,[inf,0]))
            if(slfeature('AdvancedConstantSampleTimeDisplay'))
                valData.Name=DAStudio.message('Simulink:SampleTime:SampleTimeValueNA');
            else
                valData.Name=DAStudio.message('Simulink:SampleTime:SampleTimeValueInf');
            end
        elseif((theValue(1)>=0&&(theValue(2)>=0))||isequal(theValue,[-1,-1]))
            valData.Name=['[',num2str(theValue(1)),',',num2str(theValue(2)),']'];
        elseif(theValue(1)>=0&&theValue(2)<0)
            valData.Name=num2str(theValue(1));
            h.hasExpandedVarTs{tabIdx}=-1;
        else
            valData.Name=DAStudio.message('Simulink:utility:UnknownID');
        end

    elseif(theValue(1)>0&&theValue(2)<=-20)
        cr=newline;
        lenValData=length(legendData.Owner.FullSID);
        valData=cell(lenValData,1);
        for idxVal=1:lenValData
            OwnerSID=legendData.Owner.FullSID{idxVal};
            localLoadSystem(OwnerSID,':');
            OwnerFullPath=Simulink.ID.getFullName(OwnerSID);
            valData{idxVal}.Name=get_param(OwnerFullPath,'Name');
            valData{idxVal}.Name=strrep(valData{idxVal}.Name,cr,' ');
        end
        if~isempty(legendData.Owner.LocalID)
            valData{1}.Name=['[',num2str(theValue(1)),']  ',valData{1}.Name];
        end

    elseif(theValue(1)~=-2)
        try
            valData.Name=get_param(legendData.Owner,'Name');
            if(theValue(1)~=-1)
                if((theValue(2)==0)&&(theValue(1)>=0))
                    valData.Name=num2str(theValue(1));
                elseif(theValue(1)>=0)
                    valData.Name=['[',num2str(theValue(1)),',',num2str(theValue(2)),']'];
                else
                    valData.Name=DAStudio.message('Simulink:utility:UnknownID');
                end
            end
            cr=newline;
            valData.Name=strrep(valData.Name,cr,' ');
        catch %#ok
            valData.Name=DAStudio.message('Simulink:utility:UnknownID');
        end

    else
        try
            cr=newline;
            lenValData=length(legendData.Owner.ModelReferenceHierarchy);
            valData=cell(lenValData,1);
            for idxVal=1:lenValData
                OwnerSID=legendData.Owner.ModelReferenceHierarchy{idxVal};
                localLoadSystem(OwnerSID,':');
                OwnerFullPath=Simulink.ID.getFullName(OwnerSID);
                valData{idxVal}.Name=get_param(OwnerFullPath,'Name');
                valData{idxVal}.Name=strrep(valData{idxVal}.Name,cr,' ');
            end
            if~isempty(legendData.Owner.UniqueID)
                valData{idxVal}.Name=[valData{idxVal}.Name,':',legendData.Owner.UniqueID];
            end
        catch %#ok
            valData.Name=DAStudio.message('Simulink:utility:UnknownID');
        end

    end

    if~iscell(valData)
        valData={valData};
    end
    valDataInv=valData;


    if(isequal(size(legendData.Value),[1,2])&&isnumeric(legendData.Value))
        if(isfinite(legendData.Value(1))&&legendData.Value(1)>0)
            valDataDiscretePeriod=Simulink.SampleTimeLegend.convertNumber2String(theValue(1));
            frequencyVal=1/theValue(1);
            valDataDiscreteFreq=Simulink.SampleTimeLegend.convertNumber2String(frequencyVal);

            if(theValue(2)<=-20)
                CtrlRate_substr=valData{1}.Name(length(num2str(theValue(1)))+3:end);
                valData{1}.Name=['[',valDataDiscretePeriod,'] ',CtrlRate_substr];
                valDataInv{1}.Name=['[',valDataDiscreteFreq,'] ',CtrlRate_substr];
            else
                valData{1}.Name=valDataDiscretePeriod;
                valDataInv{1}.Name=valDataDiscreteFreq;
            end
        elseif(isinf(legendData.Value(1))&&~isinf(legendData.Value(2))&&...
            legendData.Value(2)>0)
            valData{1}.Name=legendData.Annotation;

        end

    end
end





function localLoadSystem(OwnerSIDorPath,sep)

    posSep=strfind(OwnerSIDorPath,sep);
    bdname=OwnerSIDorPath(1:posSep-1);
    if(~bdIsLoaded(bdname))
        load_system(bdname);
    end
end
