function valData=getValueString(h,legendData,showAnnotations,tabIdx,tsIdx)



    valData.Type='text';
    valData.Name='';
    valData.MatlabMethod='';
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
        elseif((theValue(1)>=0)||isequal(theValue,[-1,-1]))
            valData.Name=['[',num2str(theValue(1)),',',num2str(theValue(2)),']'];
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
            valData{idxVal}.Type='hyperlink';
            valData{idxVal}.Name=strrep(valData{idxVal}.Name,cr,' ');
            valData{idxVal}.MatlabMethod='Simulink.SampleTimeLegend.hiliteVarTsBlks';
            valData{idxVal}.MatlabArgs={h,tabIdx,tsIdx,OwnerFullPath};
        end
        if~isempty(legendData.Owner.LocalID)
            valData{1}.Name=[valData{idxVal}.Name,':',legendData.Owner.LocalID];
        end

    elseif(theValue(1)~=-2)
        theOwnerBlock=legendData.Owner;

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
            valData.Type='hyperlink';
            cr=newline;
            valData.Name=strrep(valData.Name,cr,' ');
            valData.MatlabMethod=['hilite_system(''',theOwnerBlock,''')'];
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
                valData{idxVal}.Type='hyperlink';
                valData{idxVal}.Name=strrep(valData{idxVal}.Name,cr,' ');
                valData{idxVal}.MatlabMethod='Simulink.SampleTimeLegend.hiliteVarTsBlks';
                valData{idxVal}.MatlabArgs={h,tabIdx,tsIdx,OwnerFullPath};
            end
            if~isempty(legendData.Owner.UniqueID)
                valData{idxVal}.Name=[valData{idxVal}.Name,':',legendData.Owner.UniqueID];
            end
        catch %#ok
            valData.Name=DAStudio.message('Simulink:utility:UnknownID');
            valData.Type='text';
            valData.MatlabMethod='';
        end

    end





    function localLoadSystem(OwnerSIDorPath,sep)

        posSep=strfind(OwnerSIDorPath,sep);
        bdname=OwnerSIDorPath(1:posSep-1);
        if(~bdIsLoaded(bdname))
            load_system(bdname);
        end
