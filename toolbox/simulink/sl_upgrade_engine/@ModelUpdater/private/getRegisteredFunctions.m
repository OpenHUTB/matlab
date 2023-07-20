function getRegisteredFunctions(h)







    libs=which('slblocks.m','-all');
    if~isempty(libs)

        libs=cellstr(unique(char(libs),'rows'));
    end


    k=strcmp(libs,fullfile(matlabroot,'/toolbox/simulink/blocks/slblocks.m'));

    [val,idx]=max(k);
    if val~=1
        DAStudio.error('SimulinkUpgradeEngine:engine:noSlblocksFile');
    else
        tmpStr=libs{1};
        libs{1}=libs{idx};
        libs{idx}=tmpStr;
    end



    nBS=size(libs,1);
    for k=1:nBS



        fcnStr='';
        fid=fopen(libs{k},'r');

        if fid<0
            continue;
        end


        while 1
            fcnLine=fgetl(fid);
            if~ischar(fcnLine),break,end
            if contains(lower(fcnLine),'function'),break,end
        end


        while 1
            fcnLine=fgetl(fid);
            if~ischar(fcnLine),break,end
            dotsIndex=strfind(fcnLine,'...');
            if isempty(dotsIndex)
                fcnStr=[fcnStr,fcnLine,sprintf('\n')];%#ok
            else



                fcnLine(dotsIndex:dotsIndex+2)=[];
                fcnStr=[fcnStr,fcnLine];%#ok
            end
        end
        fclose(fid);


        if~isempty(fcnStr)





            clear('out');
            clear('Browser');
            clear('blkStruct');
            try
                blkStruct='';
                eval(fcnStr);
                out=blkStruct;
            catch e %#ok<NASGU>
                badSlblocksFile=fcnStr;%#ok<NASGU>
            end



            if exist('out','var')&&isstruct(out)&&isfield(out,'ModelUpdaterMethods')
                if isfield(out.ModelUpdaterMethods,'fhDetermineBrokenLinks')...
                    &&isa(out.ModelUpdaterMethods.fhDetermineBrokenLinks,'function_handle')
                    h.LinkMappingFH{end+1}=...
                    out.ModelUpdaterMethods.fhDetermineBrokenLinks;
                end
                if isfield(out.ModelUpdaterMethods,'fhUpdateModel')...
                    &&isa(out.ModelUpdaterMethods.fhUpdateModel,'function_handle')
                    h.ProductFH{end+1}=...
                    out.ModelUpdaterMethods.fhUpdateModel;
                end
                if isfield(out.ModelUpdaterMethods,'fhSeparatedChecks')...
                    &&isa(out.ModelUpdaterMethods.fhSeparatedChecks,'function_handle')
                    h.RegisteredProductFH{end+1}=...
                    out.ModelUpdaterMethods.fhSeparatedChecks;
                end
            end
        end
    end

end
