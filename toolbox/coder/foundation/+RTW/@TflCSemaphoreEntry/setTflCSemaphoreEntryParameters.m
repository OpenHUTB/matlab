function unusedParamVals=setTflCSemaphoreEntryParameters(h,varargin)












































    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    unusedParamVals={};
    myParamVals=h.setTflEntryParameters(varargin{:});

    len=length(myParamVals);
    if mod(len,2)~=0
        DAStudio.error('RTW:tfl:oddArguments');
    end

    for idx=1:2:len
        prop=findprop(h,myParamVals{idx});
        if~isempty(prop)
            set(h,myParamVals{idx},myParamVals{idx+1});
        else
            switch(myParamVals{idx})
            case 'ImplementationHeaderFile'
                h.Implementation.HeaderFile=myParamVals{idx+1};
            case 'ImplementationSourceFile'
                h.Implementation.SourceFile=myParamVals{idx+1};
            case 'ImplementationHeaderPath'
                h.Implementation.HeaderPath=myParamVals{idx+1};
            case 'ImplementationSourcePath'
                h.Implementation.SourcePath=myParamVals{idx+1};
            case 'ImplementationName'
                h.Implementation.Name=myParamVals{idx+1};
            case 'ImplementationReentrant'
                h.Implementation.Reentrant=myParamVals{idx+1};
            case 'EntryInfoAlgorithm'
                if~isempty(h.EntryInfo)
                    h.EntryInfo.Algorithm=myParamVals{idx+1};
                end
            otherwise
                unusedParamVals={unusedParamVals{:},...
                myParamVals{idx},...
                myParamVals{idx+1}};%#ok
            end
        end
    end

    if~isempty(unusedParamVals)
        params={};
        for idx=1:2:length(unusedParamVals)
            params=[params,unusedParamVals{idx}];%#ok<AGROW>
        end
        paramList=sprintf('%s\n',params{:});
        DAStudio.error('RTW:tfl:unusedArguments',paramList);
    end



