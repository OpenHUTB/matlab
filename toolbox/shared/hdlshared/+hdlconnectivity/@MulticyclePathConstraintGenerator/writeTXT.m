function writeTXT(this,mdlname)





    fname=fullfile(hdlGetCodegendir,[hdlentitytop,'_constraints.txt']);
    fid=fopen(fname,'w');



    isBuildToProtectModel=hdlgetparameter('buildtoprotectmodel');
    if(isBuildToProtectModel)
        msg=['Writing multicycle path information in ',fname];
    else
        msg=['Writing multicycle path information in ','<a href="matlab:edit(''',fname,''')">',fname,'</a>'];
    end
    hdldisp(msg);


    genby=hdlgetparameter('tool_file_comment');
    if~isempty(genby)
        genbytxt=regexp(genby,'(\w.*)','match');
        genby=genbytxt{1};
    else
        genby='\n';
    end
    createdate=datestr(now,31);


    fnamestr=strrep(fname,'\','\\');
    headertxt=...
    [repmat('%%',1,60),'\n',...
    '%%',blanks(1),'Constraints Report \n',...
    '%%',blanks(5),'Module: ',hdlentitytop,'\n',...
    '%%',blanks(5),'Model: ',mdlname,'\n',...
    '%%','\n',...
    '%%',blanks(5),'File Name: ',fnamestr,'\n',...
    '%%',blanks(5),'Created: ',createdate,'\n',...
    '%%',blanks(5),genby,...
    '%%','\n',...
    repmat('%%',1,60),'\n\n\n\n'];
    shead=sprintf(headertxt);
    fprintf(fid,'%s',shead);

    if hdlgetparameter('clockinputs')==2
        writeClockDefs(fid);
    end

    headertxt=...
    [repmat('%%',1,60),'\n',...
    '%%',blanks(1),'Multicycle Paths\n',...
    repmat('%%',1,60),'\n'];
    shead=sprintf(headertxt);
    fprintf(fid,'%s',shead);
























    if~isempty(this.mcp)
        toreg=[this.mcp.TO];
        toout=[toreg.output];
        clear toreg;
        toname=get(toout,'name');
        topath=get(toout,'path');
        toname=strcat(topath,this.delim,toname);
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


        toname=strrep(toname,this.langDeref(1),this.partSelDeref(1));
        toname=strrep(toname,this.langDeref(2),this.partSelDeref(2));



        to_booldoubidx=(tosize==0)|(tosize==1);
        towidthLeft=strtrim(cellstr(num2str(tosize-1)));

        towidth=strcat(this.arrayDeref(1),towidthLeft,':0',this.arrayDeref(2));
        [towidth{to_booldoubidx}]=deal('');
        toname=strcat(toname,towidth);



        fromreg=[this.mcp.FROM];
        fromout=[fromreg.output];




        hCD=hdlconnectivity.getConnectivityDirector;
        tU=hCD.getTimingUtil;
        relclkname=tU.topClockName;



        clear fromreg;
        fromname=get(fromout,'name');
        frompath=get(fromout,'path');
        fromname=strcat(frompath,this.delim,fromname);
        clear frompath;
        fromtype=get(fromout,'sltype');
        clear fromout;

        if iscell(fromtype)
            fromsize=cellfun(@hdlwordsize,fromtype);
        else
            fromsize=hdlwordsize(fromtype);
            fromname={fromname};
        end



        frombadnames=strfind(fromname,'<');


        assert(all(cellfun(@isempty,frombadnames)));

        fromname=strrep(fromname,this.langDeref(1),this.partSelDeref(1));
        fromname=strrep(fromname,this.langDeref(2),this.partSelDeref(2));


        from_booldoubidx=(fromsize==0)|(fromsize==1);
        fromwidthLeft=strtrim(cellstr(num2str(fromsize-1)));

        fromwidth=strcat(this.arrayDeref(1),fromwidthLeft,':0',this.arrayDeref(2));
        [fromwidth{from_booldoubidx}]=deal('');
        fromname=strcat(fromname,fromwidth);

        pmstr=cellfun(@num2str,{this.mcp.pathmult},...
        'UniformOutput',false);
        constraint=strcat({'FROM : '},fromname,...
        {'; TO : '},toname,...
        {'; PATH_MULT : '},pmstr',...
        {'; RELATIVE_CLK : source, '},...
        relclkname,{';'});

        fprintf(fid,'%s\n',constraint{:});
    end
    fclose(fid);
end

function writeClockDefs(fid)
    hCD=hdlconnectivity.getConnectivityDirector;
    tU=hCD.getTimingUtil;
    fastestClock=tU.topClockName;
    hD=hdlcurrentdriver;
    p=hD.PirInstance;
    gp=pir;
    reportData=gp.getClockReportData;
    topNetworkName=p.getTopNetwork.Name;

    headertxt=...
    [repmat('%%',1,60),'\n',...
    '%%',blanks(1),'Clock Definitions\n',...
    repmat('%%',1,60),'\n'];
    shead=sprintf(headertxt);
    fprintf(fid,'%s',shead);

    for ii=1:length(reportData.clockData)
        fprintf(fid,'CLOCK: %s.%s ',topNetworkName,reportData.clockData(ii).name);
        if reportData.clockData(ii).ratio~=1
            fprintf(fid,'BASE_CLOCK: %s MULTIPLIER: %d ',fastestClock,reportData.clockData(ii).ratio);
        end
        fprintf(fid,'PERIOD: %g\n',reportData.clockData(ii).sampleTime);
    end
    fprintf(fid,'\n\n');
end



