function[reNames,imNames]=getHDLSignals(this,nameType,portIdx)






    if isa(portIdx,'struct')


        port=portIdx;
        pHan=port.SLPortHandle;
        pName=port.loggingPortName;
        switch nameType
        case{'in','force','force_map'}
            for ii=1:numel(this.InportSrc)
                if this.InportSrc(ii).SLPortHandle==pHan&&...
                    strcmp(this.InportSrc(ii).loggingPortName,pName)
                    portIdx=ii;
                    break;
                end
            end
        case{'out','expected'}
            for ii=1:numel(this.OutportSnk)
                if this.OutportSnk(ii).SLPortHandle==pHan&&...
                    strcmp(this.OutportSnk(ii).loggingPortName,pName)
                    portIdx=ii;
                    break;
                end
            end
        end
    else

        switch nameType
        case{'in','force','force_map'}
            port=this.InportSrc(portIdx);
        case{'out','expected'}
            port=this.OutportSnk(portIdx);
        end
    end

    if strcmp(nameType,'in')
        names=port.HDLPortName;
    elseif strcmp(nameType,'out')
        names=port.HDLPortName;
    elseif strcmp(nameType,'force')
        names=this.hdlSignals.ForceSignals(portIdx);
    elseif strcmp(nameType,'force_map')
        names=this.hdlSignals.ForceSignalMap(portIdx);
    elseif strcmp(nameType,'expected')
        names=this.hdlSignals.ExpectedSignals(portIdx);
    end



    if iscell(names)
        if iscell(names{1})
            allNames=cell(1,length(names).*length(names{1}));
        else
            allNames=cell(1,length(names));
        end
    end

    index=1;
    for ii=1:length(names);
        currentPort=names{ii};
        if iscell(currentPort)
            for jj=1:length(currentPort)
                allNames{index}=currentPort{jj};
                index=index+1;
            end
        else
            allNames{index}=currentPort;
            index=index+1;
        end
    end

    if this.isPortComplex(port)&&nargout==2

        numPerPart=length(allNames)/2;
        reNames=allNames(1:numPerPart);
        imNames=allNames(numPerPart+1:end);
    else
        reNames=allNames;
        imNames={};
    end
end
