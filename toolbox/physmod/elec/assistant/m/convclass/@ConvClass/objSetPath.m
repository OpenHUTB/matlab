function objSetPath(obj,varargin)


    in=varargin{1};
    blockDestinationRoot=obj.NewPath;
    if isprop(obj,'BlockOption')
        nOptions=size(obj.BlockOption,1);
    else
        nOptions=0;
    end

    if nOptions==0
        obj.NewBlockPath=blockDestinationRoot;
    else
        for optionIdx=1:nOptions
            options=obj.BlockOption{optionIdx,1};
            if isempty(options)

                optionSuffix=obj.BlockOption{optionIdx,2};
                if isempty(optionSuffix)
                    obj.NewBlockPath=blockDestinationRoot;
                else
                    obj.NewBlockPath=[blockDestinationRoot,'_',optionSuffix];
                end

                break;
            end
            optionNames=options(:,1);
            optionValues=options(:,2);
            optionActualValues=cellfun(@(x)getValue(in,x),optionNames,'UniformOutput',false);
            optionActualValues=strtrim(optionActualValues);
            oldstr='''';
            newstr='';
            optionActualValues=replace(optionActualValues,oldstr,newstr);
            if all(strcmp(optionValues,optionActualValues))
                optionSuffix=obj.BlockOption{optionIdx,2};
                if isempty(optionSuffix)
                    obj.NewBlockPath=blockDestinationRoot;
                else
                    obj.NewBlockPath=[blockDestinationRoot,'_',optionSuffix];
                end

                break;
            end
        end
    end
end
