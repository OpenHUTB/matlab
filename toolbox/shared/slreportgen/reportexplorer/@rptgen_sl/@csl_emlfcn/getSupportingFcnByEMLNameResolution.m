function fcnData=getSupportingFcnByEMLNameResolution(this,chart)










    userMsg=getString(message('RptgenSL:csl_emlfcn:user'));
    matlabMsg=getString(message('RptgenSL:csl_emlfcn:matlab'));

    fcnInfo=sfprivate('get_eml_name_resolution_info',chart.id);

    n=numel(fcnInfo);
    fcnNames=cell(1,n);
    fcnPaths=cell(1,n);
    fcnTypes=cell(1,n);
    j=1;
    for i=1:n


        if startsWith(fcnInfo(i).resolved,'[E]')
            fcnNames{j}=fcnInfo(i).name;
            fcnPaths{j}=strrep(...
            regexprep(fcnInfo(i).resolved,'^\[[^\]]*]',''),...
            '/',...
            filesep);
            fcnTypes{j}=userMsg;
            j=j+1;

        elseif(this.supportFunctionsToInclude==1)...
            &&~startsWith(fcnInfo(i).name,'eml')...
            &&~startsWith(fcnInfo(i).name,'coder.internal.')
            fcnNames{j}=fcnInfo(i).name;
            fcnPaths{j}='';
            fcnTypes{j}=matlabMsg;
            j=j+1;
        end
    end

    fcnNames(j:end)=[];
    fcnPaths(j:end)=[];
    fcnTypes(j:end)=[];

    fcnData=struct('Name',fcnNames,'Path',fcnPaths,'Type',fcnTypes);
end