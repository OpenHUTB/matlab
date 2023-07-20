function[ret,name,retIdx,elementCache]=...
    locGetWrapperWithNotFoundWarning(this,elementCache,searchArg,varargin)


    [varargin{:}]=convertStringsToChars(varargin{:});
    searchArg=convertStringsToChars(searchArg);

    [ret,name,retIdx,found,searchOpts,elementCache]=locGet(this,elementCache,searchArg,varargin{:});


    locReportNotFoundWarning(found,searchOpts);
end


function locReportNotFoundWarning(found,searchOpts)

    if(~found)
        paramStr='';
        if strcmpi(searchOpts.propName,'BlockPath')
            bpstr=message('SimulationData:Objects:BlockPathPathHeading').getString;
            bpath=Simulink.SimulationData.BlockPath(searchOpts.searchArg);
            for bpidx=1:bpath.getLength
                bpstr=strcat(bpstr,sprintf('\n%s',bpath.getBlock(bpidx)));
            end
            paramStr=strcat(paramStr,bpstr);
        elseif~isempty(searchOpts.propName)
            paramStr=strcat(paramStr,searchOpts.propName);
        else
            paramStr=strcat(paramStr,strcat(searchOpts.searchArg));
        end


        if~isempty(searchOpts.delimChar)
            paramStr=horzcat(paramStr,' Delimiter ',searchOpts.delimChar);
        end

        msg=message(...
        'SimulationData:Objects:InvalidAccessToDatasetElement',...
        paramStr);

        warning(msg);
    end
end

