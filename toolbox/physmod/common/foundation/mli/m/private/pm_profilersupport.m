function pm_profilersupport(varargin)
















    persistent outputMode;




    if isempty(outputMode)
        outputMode=0;
    end

    if nargin==1



        outputMode=varargin{1};
    else



        if outputMode~=1
            pm_assert(nargin==2);
            iProfileHandle=varargin{1};
            iBlockName=varargin{2};




            iVariableName=strrep([strrep(iBlockName,'/','_'),'_profiler_info'],' ','_');




            profInfo=getProfInfo(iProfileHandle);
            assignin('base',iVariableName,profInfo);




            if outputMode==0



                pm_profilerreport(profInfo,pwd,iVariableName,iBlockName);
            end
        end
    end

end




function profInfo=getProfInfo(iProfileHandle)


    h=iProfileHandle;
    callstats(h,'stop');
    [ft,fh,cp,name,cs]=callstats(h,'stats');%#ok
    profInfo.FunctionTable=ft;
    profInfo.ClockPrecision=cp;
    profInfo.ClockSpeed=cs;
    profInfo.Name=name;

end


