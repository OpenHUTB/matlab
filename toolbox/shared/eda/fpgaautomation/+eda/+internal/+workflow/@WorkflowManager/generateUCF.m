function generateUCF(h)





    ucf_subscript='.ucf';

    hdlcData=h.mWorkflowInfo.hdlcData;
    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;

    moduleName=hdlcData.dutName;
    if userParam.genClockModule
        moduleName=[moduleName,tdkParam.clkWrapperName];
    end


    mcpInfo=hdlcData.MCPinfo;
    if isempty(mcpInfo)
        return;
    end


    mcpObj=mcpInfo.mcp;
    delim=mcpInfo.delim;
    langDeref=mcpInfo.langDeref;
    arrayDeref=mcpInfo.arrayDeref;



    codegendir=hdlcData.codegenDir;
    topEntity=hdlcData.dutName;
    mdlname=hdlcData.modelName;





    h.makeHdlDir;


    fname=fullfile(codegendir,[topEntity,ucf_subscript]);
    fid=fopen(fname,'w');


    msg=['Writing multicycle path constraint in ',hdlgetfilelink(fname)];
    dispFpgaMsg(msg);
    disp(' ');

    cm='#';
    nl=char(10);


    genby=getGenByText;
    createdate=datestr(now,31);

    fnamestr=strrep(fname,'\','\\');
    headertxt=...
    [repmat(cm,1,60),nl...
    ,cm,blanks(1),'UCF Constraint File',nl...
    ,cm,blanks(5),'Module: ',moduleName,nl...
    ,cm,blanks(5),'Model: ',mdlname,'.mdl',nl...
    ,cm,nl...
    ,cm,blanks(5),'File Name: ',fnamestr,nl...
    ,cm,blanks(5),'Created: ',createdate,nl...
    ,cm,blanks(5),genby,nl...
    ,cm,nl...
    ,repmat(cm,1,60),nl,nl...
    ,cm,' This constraint file is provided as an example. You must',nl...
    ,cm,' determine if it is suitable for your design, and add it',nl...
    ,cm,' to your Xilinx ISE project manually.',nl,nl];

    shead=sprintf(headertxt);
    fprintf(fid,'%s',shead);




    clkperiod=userParam.clkinPeriod;
    clkname=hdlcData.clockname;
    tnm_name=['"TN_',clkname,'"'];
    timespec_name=['"TS_',clkname,'"'];

    clkucf=[...
    repmat(cm,1,60),nl...
    ,cm,blanks(1),'Clock period constraint',nl...
    ,repmat(cm,1,60),nl...
    ,cm,' Clock period must be specified to define multicycle path',nl...
    ,cm,' constraints. If not specified elsewhere, uncomment the',nl...
    ,cm,' following constraints, and modify the clock name and clock',nl...
    ,cm,' period to match your design.',nl...
    ,cm,nl...
    ,cm,' NET "',clkname,'" TNM_NET = ',tnm_name,';',nl...
    ,cm,' TIMESPEC ',timespec_name,' = PERIOD ',tnm_name,' '...
    ,clkperiod,' ns HIGH 50%;',nl,nl...
    ,repmat(cm,1,60),nl...
    ,cm,blanks(1),'Multicycle path constraint',nl...
    ,repmat(cm,1,60),nl...
    ];

    fprintf(fid,'%s',clkucf);
























    if~isempty(mcpObj),

        if userParam.genClockModule

            search_str=['^',topEntity,'/'];

            entityPrefix='u_';
            repl_str=[entityPrefix,topEntity,'/'];
        else
            search_str=['^',topEntity,'/'];
            repl_str='';
        end


        toreg=[mcpObj.TO];
        toout=[toreg.output];
        clear toreg;
        toname=get(toout,'name');
        topath=get(toout,'path');
        toname=strcat(topath,delim,toname);
        clear topath;
        totype=get(toout,'sltype');
        clear toout;

        if iscell(totype)
            tosize=cellfun(@hdlwordsize,totype);
        else
            tosize=hdlwordsize(totype);
            toname={toname};
        end
        clear totype;




        tobadnames=strfind(toname,'<');


        assert(all(cellfun(@isempty,tobadnames)));








        vectend_str='_VECTEND__';




        toname=strrep(toname,langDeref(1),'_');
        toname=strrep(toname,langDeref(2),vectend_str);


        toname=strrep(toname,'.','/');

        toname=regexprep(toname,search_str,repl_str);



        to_booldoubidx=(tosize==0)|(tosize==1);
        towidthLeft=strtrim(cellstr(num2str(tosize-1)));

        towidth=strcat(arrayDeref(1),towidthLeft,':0',arrayDeref(2));
        [towidth{1:end}]=deal('_*');
        [towidth{to_booldoubidx}]=deal('');
        toname=strcat(toname,towidth);


        fromreg=[mcpObj.FROM];
        fromout=[fromreg.output];

        clear fromreg;
        fromname=get(fromout,'name');
        frompath=get(fromout,'path');
        fromname=strcat(frompath,delim,fromname);
        clear frompath;
        fromtype=get(fromout,'sltype');
        clear fromout;

        if iscell(fromtype),
            fromsize=cellfun(@hdlwordsize,fromtype);
        else
            fromsize=hdlwordsize(fromtype);
            fromname={fromname};
        end



        frombadnames=strfind(fromname,'<');


        assert(all(cellfun(@isempty,frombadnames)));



        fromname=strrep(fromname,langDeref(1),'_');
        fromname=strrep(fromname,langDeref(2),vectend_str);


        fromname=strrep(fromname,'.','/');

        fromname=regexprep(fromname,search_str,repl_str);


        from_booldoubidx=(fromsize==0)|(fromsize==1);
        fromwidthLeft=strtrim(cellstr(num2str(fromsize-1)));

        fromwidth=strcat(arrayDeref(1),fromwidthLeft,':0',arrayDeref(2));
        [fromwidth{1:end}]=deal('_*');
        [fromwidth{from_booldoubidx}]=deal('');
        fromname=strcat(fromname,fromwidth);

        pmstr=cellfun(@num2str,{mcpObj.pathmult},...
        'UniformOutput',false);

        numstr=cell(numel(fromname),1);
        for ii=1:numel(fromname),numstr{ii}=num2str(ii);end
        constraint=strcat(...
        {'INST "'},fromname,{'" TNM = MC'},numstr,{'_SRC;'},...
        {char(10)},...
        {'INST "'},toname,{'" TNM = MC'},numstr,{'_END;'},...
        {char(10)},...
        {'TIMESPEC TS_MC'},numstr,...
        {' = FROM "MC'},numstr,{'_SRC" TO "MC'},numstr,{'_END" '},...
        {timespec_name},{' * '},pmstr',{';'},...
        {char(10)},{char(10)}...
        );

        constraint=strrep(constraint,[vectend_str,'<*>'],'_*');


        constraint=strrep(constraint,vectend_str,'');
        fprintf(fid,'%s',constraint{:});

    end
    fclose(fid);
end


function str=getGenByText(~)

    mver=ver('matlab');
    hver=ver('hdlverifier');
    str=['Generated by ',mver.Name,' ',mver.Version,' and '...
    ,hver.Name,' ',hver.Version];
end

