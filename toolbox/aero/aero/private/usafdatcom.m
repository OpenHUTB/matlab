function[casenoout,casedata]=usafdatcom(files,usenan,verbose)








    casenoout=0;

    for fcnt=1:length(files)
        filename=files(fcnt);
        if(verbose=="1")
            fprintf('\nLoading file ''%s''.\n',filename)
        elseif(verbose=="2")
            hw=waitbar(0,'Progress: 0%','name',sprintf('Loading: %s',filename));
            for z=0.1:0.1:0.2
                waitbar(z,hw)
                pause(0.1)
            end
        end
        caseno=casenoout+1;
        casenoout=casenoout+1;
        firstinput=1;
        firstoutput=1;
        try
            fid=fopen(filename,'r');
            if(fid<0)
                error(message('aero:loadfiles:cannotOpen',filename));
            end

            state='checkfile';
            linetype='';
            linetype_old='';
            line_old='';
            state_old='';
            input=true;
            appendflg=false;
            sbuild=1;
            scnt=1;
            dbuild=1;
            dcnt=1;
            casesetup=struct('case','','version',[]);

            casedata{caseno}=casesetup;%#ok<AGROW>


            while~feof(fid)
                line=fgetl(fid);

                if input
                    if(verbose=="1")
                        if firstinput
                            fprintf('Reading input data from file ''%s''.\n',filename)
                            firstinput=0;
                        end
                    elseif(verbose=="2")
                        z=z+0.01;
                        if z>0.5
                            z=0.5;
                        end
                        set(hw,'name',sprintf('Reading input data: %s',filename))
                        waitbar(z,hw,sprintf('Progress: %3.0f%%',z*100))
                    end

                    linetype=inputlinetype();

                    [state,input]=inputreaderstate(state,input);

                    switch state
                    case 'lost'

                        lostwarning();

                    case 'exit'

                        error(message('aero:datcomimport:invalidFile',filename));
                    otherwise

                    end

                    line_old=getinputdata(line_old);

                else
                    if(verbose=="1")
                        if firstoutput
                            fprintf('Reading output data from file ''%s''.',filename)
                            firstoutput=0;
                        end
                    elseif(verbose=="2")
                        z=z+0.01;
                        if z>0.95
                            z=0.95;
                        end
                        set(hw,'name',sprintf('Reading output data: %s',filename))
                        waitbar(z,hw,sprintf('Progress: %3.0f%%',z*100))
                    end

                    linetype=outputlinetype();

                    state=outputreaderstate(state);

                    if strcmp(state,'lost')

                        lostwarning();
                    end

                    getoutputdata();
                end
            end
            fclose(fid);
            if(verbose=="2")
                set(hw,'Name',sprintf('Reading completed: %s',filename))
                waitbar(1,hw,'Progress: 100%')
                pause(0.5)
            end
        catch readError
            if(exist('fid','var')&&~any(fid==[-1,0,1,2]))
                fclose(fid);
            end
            if exist('hw')%#ok<EXIST>
                close(hw);
            end
            rethrow(readError)
        end
        if exist('hw')%#ok<EXIST>
            close(hw);
        end
    end


    function linetype=inputlinetype()
        unusedii={'\<\$SYNTHS\>','\<\$WGSCHR\>','\<\$HTSCHR\>'...
        ,'\<\$VTSCHR\>','\<\$VFSCHR\>','\<\$EXPR'...
        ,'\<\$INLET\>','\<\$PROTUB\>'};
        unusediv={'\<NAMELIST\>','\<NACA\>|\','\<DUMP\>','\<PLOT\>'...
        ,'\<FORMAT\>','\<INCRMT\>','\<NOGO\>','\<WRITE\>'...
        ,'\<DELETE\>','\<PRESSURES\>','\<PRINT\>','\<SPIN\>'};
        disclaimer={...
'^THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION$'...
        ,'^IS RELEASED "AS IS"\.  THE U.S. GOVERNMENT MAKES NO$'...
        ,'^WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING$'...
        ,'^THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION,$'...
        ,'^INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OF$'...
        ,'^MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE\.$'...
        ,'^IN NO EVENT WILL THE U\.S\. GOVERNMENT BE LIABLE FOR ANY$'...
        ,'^DAMAGES, INCLUDING LOST PROFITS, LOST SAVINGS OR OTHER$'...
        ,'^INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE$'...
        ,'^USE, OR INABILITY TO USE, THIS SOFTWARE OR ANY$'...
        ,'^ACCOMPANYING DOCUMENTATION, EVEN IF INFORMED IN ADVANCE$'...
        ,'^OF THE POSSIBILITY OF SUCH DAMAGES\.$'...
        ,'^\*{52}$'};
        pwr={'\<\$PROPWR\>','\<\$JETPWR\>'};
        eoi={'\<AUTOMATED STABILITY\>'...
        ,'\<THE FOLLOWING IS A LIST OF ALL INPUT CARDS\>'...
        ,'\<FOLLOWING ARE THE CARDS INPUT FOR THIS CASE\>'};
        ierror={'\<MISSING NAME\>','\<UNKNOWN NAME\>'...
        ,'\<NAMELIST INPUT ERROR\>','\*\* ERROR \*\*'...
        ,'\<ERROR -\>','\<ERROR\(S\)\>','\<ERROR TYPE\>'...
        ,'\<ERROR IN CARD\>','\<ILLEGAL \>','\<CASES EXCEEDS\>'...
        ,'\<FIT IN ERROR\>'};

        if(length(line)<4)
            linetype='blank';

        elseif any(~cellfun('isempty',regexp(strtrim(line),disclaimer,'once')))

            linetype='disclaimer';
        elseif any(~cellfun('isempty',regexp(line,{...
            '\<\*  THE USAF AUTOMATED MISSILE DATCOM PROGRAM       \*\>',...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 3\/99 \*\*\*\*\*\>$',...
            },'once')))
            linetype='mdatcom';
        elseif~isempty(regexp(line,...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 07\/07 \*\*\*\*\*\>$',...
            'once'))
            linetype='mdatcom07';
        elseif~isempty(regexp(line,...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 08\/08 \*\*\*\*\*\>$',...
            'once'))
            linetype='mdatcom08';
        elseif~isempty(regexp(line,...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 03\/11 \*\*\*\*\*\>$',...
            'once'))
            linetype='mdatcom11';
        elseif~isempty(regexp(line,...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 2014 \*\*\*\*\*\>$',...
            'once'))
            linetype='mdatcom14';
        elseif~isempty(regexp(line,...
            '\<\*    USAF STABILITY AND CONTROL  DIGITAL DATCOM    \*\>',...
            'once'))
            linetype='ddatcom';
        elseif~isempty(regexp(line,'\<CASEID\>','once'))
            linetype='caseid';
        elseif any(~cellfun('isempty',regexp(line,unusedii,'once')))
            linetype='unused';

        elseif any(~cellfun('isempty',regexp(line,unusediv,'once')))
            linetype='unused';

        elseif any(~cellfun('isempty',regexp(line,ierror,'once')))
            linetype='input error';

        elseif~isempty(regexp(line,'\<BUILD\>','once'))
            linetype='build';
        elseif~isempty(regexp(line,'\<DAMP\>','once'))
            linetype='damp';
        elseif~isempty(regexp(line,'\<DERIV\>','once'))

            linetype='deriv';
        elseif~isempty(regexp(line,'\<NO LAT\>','once'))
            linetype='nolat';
        elseif~isempty(regexp(line,'\<DIM ','once'))

            linetype='dim';
        elseif~isempty(regexp(line,'\<NEXT CASE\>','once'))
            linetype='end of case';
        elseif~isempty(regexp(line,'\<PART\>','once'))
            linetype='part';
        elseif~isempty(regexp(line,'\<SAVE\>','once'))
            linetype='save';
        elseif~isempty(regexp(line,'\<TRIM\>','once'))
            linetype='trim';
        elseif any(~cellfun('isempty',regexp(line,{'\<\$BODY\>','\<\$AXIBOD\>','\<\$ELLBOD\>'},'once')))
            linetype='body';
        elseif any(~cellfun('isempty',regexp(line,{'\<\$VTPLNF\>','\<\$TVTPAN\>'},'once')))
            linetype='vtail';
        elseif~isempty(regexp(line,'\<\$VFPLNF\>','once'))
            linetype='vfin';
        elseif~isempty(regexp(line,'\<\$FINSET1\>','once'))
            linetype='fin1';
        elseif~isempty(regexp(line,'\<\$FINSET2\>','once'))
            linetype='fin2';
        elseif~isempty(regexp(line,'\<\$FINSET3\>','once'))
            linetype='fin3';
        elseif~isempty(regexp(line,'\<\$FINSET4\>','once'))
            linetype='fin4';
        elseif~isempty(regexp(line,'\<\$DEFLCT\>','once'))
            linetype='deflect';
        elseif~isempty(regexp(line,'\<\$WGPLNF\>','once'))
            linetype='wsspn';
        elseif~isempty(regexp(line,'\<\$HTPLNF\>','once'))
            linetype='hsspn';
        elseif~isempty(regexp(line,'\<\$SYMFLP\>','once'))
            linetype='symflp';
        elseif~isempty(regexp(line,'\<\$ASYFLP\>','once'))
            linetype='asyflp';
        elseif~isempty(regexp(line,'\<\$CONTAB\>','once'))

            linetype='contab';
        elseif~isempty(regexp(line,'\<\$TRNJET\>','once'))

            linetype='tjet';
        elseif any(~cellfun('isempty',regexp(line,{'\<\$HYPEFF\>','\<HYPER\>','\<SOSE\>'},'once')))

            linetype='hypers';
        elseif~isempty(regexp(line,'\<\$LARWB\>','once'))

            linetype='lb';
        elseif any(~cellfun('isempty',regexp(line,pwr,'once')))

            linetype='pwr';
        elseif~isempty(regexp(line,'\<\$GRNDEF\>','once'))

            linetype='grndef';
        elseif~isempty(regexp(line,'\<\$FLTCON\>','once'))
            linetype='fltcon';
        elseif any(~cellfun('isempty',regexp(line,{'\<\$OPTINS\>','\<\$REFQ\>'},'once')))
            linetype='optins';
        elseif any(~cellfun('isempty',regexp(line,eoi,'once')))
            linetype='end of input';
        else
            linetype=testline();
        end

        function linetype=testline()

            if appendflg
                linetype='append';
            else
                linetype='unknown';
            end
        end

        if(casedata{1}.version~=1976)

            line=line(5:end);
        end
    end

    function[state,input]=inputreaderstate(state,input)
        if~strcmp(linetype,'blank')

            reading={'unused','optins','append','fltcon'...
            ,'hypers','lb','pwr','grndef'...
            ,'tjet','build','caseid','damp'...
            ,'nolat','deriv','dim','save','part'...
            ,'trim','wsspn','hsspn','symflp'...
            ,'asyflp','contab','unknown','disclaimer'...
            ,'body','vtail','vfin','fin1'...
            ,'fin2','fin3','fin4','deflect'};
            dataread={'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'};

            switch state
            case 'checkfile'
                statecell={'exit','checkfile','enter','enter','enter','enter','enter','enter'};
                typecell={'disclaimer','ddatcom','mdatcom','mdatcom07','mdatcom08','mdatcom11','mdatcom14'};

            case 'enter'
                statecell=[{'lost','error'},dataread];
                typecell=[{'input error'},reading];

            case 'dataread'
                statecell=[{'lost','error','EOI','EOC'},dataread];
                typecell=[{'input error','end of input','end of case'}...
                ,reading];

            case 'EOC'
                statecell=[{'lost','error','EOI'},dataread];
                typecell=[{'input error','end of input'},reading];

            case 'EOI'
                statecell={'lost','error','EOI','EOI','EOI'...
                ,'EOI','EOI','EOI','EOI','EOI'...
                ,'EOI','EOI','EOI','EOI','EOI'...
                ,'EOI','EOI','EOI','EOI','EOI'...
                ,'EOI','EOI','EOI','EOI','EOI'...
                ,'EOI','EOI'};
                typecell=[{'input error','end of input','end of case'}...
                ,reading];

            case 'error'
                statecell={'error','error','error','error','error'...
                ,'error','error','error','error','error'...
                ,'error','error','error','error','error'...
                ,'error','error','error','error','error'...
                ,'error','error','error','error','error'...
                ,'error','error'};
                typecell=[{'input error','end of input','end of case'}...
                ,reading];

            case 'exit'
                statecell={'exit','exit'};
                typecell={''};

            otherwise
                statecell={'lost','lost','lost','lost','lost'...
                ,'lost','lost','lost','lost','lost'...
                ,'lost','lost','lost','lost','lost'...
                ,'lost','lost','lost','lost','lost'...
                ,'lost','lost','lost','lost','lost'...
                ,'lost','lost'};
                typecell=[{'input error','end of input','end of case'}...
                ,reading];
            end
            stateidx=find(strcmp(typecell,linetype));
            if isempty(stateidx)
                stateidx=0;
            end
            state=statecell{stateidx+1};

            if strcmp(state,'EOI')
                input=false;
            end

        end
    end

    function line_old=getinputdata(line_old)
        line=strtrim(line);
        switch linetype
        case 'blank'

        case 'append'
            appendactions()
        case 'build'
            buildactions()
        case 'caseid'
            caseidactions()
        case 'damp'
            dampactions()
        case 'nolat'
            casedata{caseno}.nolat=true;
            if((casedata{caseno}.version==2007)||(casedata{caseno}.version==2008)||...
                (casedata{caseno}.version==2011)||(casedata{caseno}.version==2014))
                casedata{caseno}.nolat_namelist=true;
            end
        case 'ddatcom'

            casesetup=struct('case','','mach',[],'alt',[],'alpha',[],...
            'nmach',0,'nalt',0,'nalpha',0,'rnnub',[],'hypers',false,'loop',1,...
            'sref',[],'cbar',[],'blref',[],'dim','ft','deriv','deg',...
            'stmach',0.6,'tsmach',1.4,'save',false,'stype',[],'trim',false,...
            'damp',false,'build',1,'part',false,'highsym',false,'highasy',false,...
            'highcon',false,'tjet',false,'hypeff',false,'lb',false,'pwr',false,...
            'grnd',false,'wsspn',1,'hsspn',1,'ndelta',0,'delta',[],'deltal',[],...
            'deltar',[],'ngh',0,'grndht',[],...
            'config',struct('downwash',false,'body',false,'wing',false,...
            'htail',false,'vtail',false,'vfin',false),'version',1976);
            casedata{caseno}=casesetup;
        case{'mdatcom','mdatcom07','mdatcom08','mdatcom11','mdatcom14'}

            casesetup=struct('case','','mach',[],'alt',[],'alpha',[],...
            'nmach',0,'nalt',1,'nalpha',0,'rnnub',[],'beta',0,...
            'phi',0,'loop',1,...
            'sref',[],'cbar',[],'blref',[],'dim','ft','deriv','deg',...
            'save',false,'stype',[],'trim',false,...
            'damp',false,'build',1,'part',false,...
            'hypeff',false,...
            'ngh',0,'nolat',false,...
            'config',struct('body',false,...
            'fin1',struct('avail',false,'npanel',[],'delta',[]),...
            'fin2',struct('avail',false,'npanel',[],'delta',[]),...
            'fin3',struct('avail',false,'npanel',[],'delta',[]),...
            'fin4',struct('avail',false,'npanel',[],'delta',[])));
            switch linetype
            case 'mdatcom'
                casesetup.version=1999;
            case 'mdatcom07'
                casesetup.version=2007;
                casesetup.nolat_namelist=false;
            case 'mdatcom08'
                casesetup.version=2008;
                casesetup.nolat_namelist=false;
            case 'mdatcom11'
                casesetup.version=2011;
                casesetup.nolat_namelist=false;
            case 'mdatcom14'
                casesetup.version=2014;
                casesetup.nolat_namelist=false;
            end
            casedata{caseno}=casesetup;
        case 'deriv'
            derivactions()
        case 'dim'
            dimactions()
        case 'disclaimer'

        case 'end of case'
            eocactions()
        case 'part'
            partactions()
        case 'save'
            saveactions()
        case 'trim'
            trimactions()
        case 'body'
            casedata{caseno}.config.body=true;
        case 'vtail'
            casedata{caseno}.config.vtail=true;
        case 'vfin'
            casedata{caseno}.config.vfin=true;
        case 'fin1'
            casedata{caseno}.config.fin1.avail=true;
            casedata{caseno}.config.fin1.npanel=4;
            if isempty(casedata{caseno}.config.fin1.delta)
                casedata{caseno}.config.fin1.delta=[0,0,0,0];
            end
            finactions()
        case 'fin2'
            casedata{caseno}.config.fin2.avail=true;
            casedata{caseno}.config.fin2.npanel=4;
            if isempty(casedata{caseno}.config.fin2.delta)
                casedata{caseno}.config.fin2.delta=[0,0,0,0];
            end
            finactions()
        case 'fin3'
            casedata{caseno}.config.fin3.avail=true;
            casedata{caseno}.config.fin3.npanel=4;
            if isempty(casedata{caseno}.config.fin3.delta)
                casedata{caseno}.config.fin3.delta=[0,0,0,0];
            end
            finactions()
        case 'fin4'
            casedata{caseno}.config.fin4.avail=true;
            casedata{caseno}.config.fin4.npanel=4;
            if isempty(casedata{caseno}.config.fin4.delta)
                casedata{caseno}.config.fin4.delta=[0,0,0,0];
            end
            finactions()
        case 'deflect'
            deflectactions()
        case 'wsspn'
            wsspnactions()
        case 'hsspn'
            hsspnactions()
        case 'symflp'
            symflpactions()
        case 'asyflp'
            asyflpactions()
        case 'contab'
            contabactions()
        case 'tjet'
            tjetactions()
        case 'hypers'
            hypersactions()
        case 'lb'
            lbactions()
        case 'pwr'
            pwractions()
        case 'grndef'
            grndefactions()
        case 'fltcon'
            fltconactions()
        case 'optins'
            optinsactions()
        case{'unused','unknown'}
            unactions()
        case 'end of input'
            eiactions()
        case 'input error'
            ieactions()
        otherwise

            lostwarning();
        end

        function appendactions()
            switch state
            case 'dataread'
                if(strcmpi(line(end),'$')||strcmpi(line(end-3:end),'$end'))||(strcmpi(line(end),'&'))
                    line=[line_old,line];

                    switch linetype_old
                    case 'wsspn'
                        casedata{caseno}.wsspn=sspnvalue(casedata{caseno}.wsspn);
                    case 'hsspn'
                        casedata{caseno}.hsspn=sspnvalue(casedata{caseno}.hsspn);
                    case 'symflp'
                        symflpvalue();
                    case 'asyflp'
                        asyflpvalue();
                    case 'tjet'
                        tjetvalue();
                    case 'hypers'
                        hypersvalue();
                    case 'grndef'
                        grndefvalue();
                    case 'fltcon'
                        fltconvalue();
                    case 'optins'
                        optinsvalue();
                    case 'lb'
                        lbvalue();
                    case{'fin1','fin2','fin3','fin4'}
                        finvalue();
                    case 'deflect'
                        deflectvalue();
                    otherwise
                        error(message('aero:datcomimport:invalidType',linetype_old));
                    end
                    appendflg=false;
                    linetype_old='';
                else
                    line_old=[line_old,line];
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function buildactions()
            switch state
            case 'dataread'
                casedata{caseno}.build=10;
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function caseidactions()
            switch state
            case 'dataread'
                casedata{caseno}.case=strtrim(line(7:end));
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function dampactions()
            switch state
            case 'dataread'
                casedata{caseno}.damp=true;
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function derivactions()
            switch state
            case 'dataread'

                if~((casedata{caseno}.version~=1976)&&...
                    strcmpi(casedata{caseno}.deriv,'rad'))


                    casedata{caseno}.deriv=lower(strtrim(line(6:end)));
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function dimactions()
            switch state
            case 'dataread'

                casedata{caseno}.dim=lower(strtrim(line(4:end)));
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function eocactions()
            switch state
            case 'dataread'

            case 'EOC'
                setbuildnumber();
                [casedata,caseno]=nextcase(casedata,caseno,casesetup);


            otherwise
                invaliddataerror();
            end
        end

        function partactions()
            switch state
            case 'dataread'
                casedata{caseno}.part=true;
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function saveactions()
            switch state
            case 'dataread'
                casedata{caseno+1}=casedata{caseno};

                casedata{caseno+1}.trim=casesetup.trim;
                casedata{caseno+1}.damp=casesetup.damp;
                casedata{caseno+1}.case=casesetup.case;
                casedata{caseno+1}.part=casesetup.part;
                casedata{caseno+1}.build=casesetup.build;
                casedata{caseno+1}.save=casesetup.save;
                casedata{caseno}.save=true;
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function trimactions()
            switch state
            case 'dataread'
                casedata{caseno}.trim=true;
                if(casedata{caseno}.version~=1976)
                    casedata{caseno}.nolat=true;
                    if(casedata{caseno}.build>1)

                        casedata{caseno}.build=1;
                    end
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function wsspnactions()
            switch state
            case 'dataread'
                casedata{caseno}.config.wing=true;
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    casedata{caseno}.wsspn=sspnvalue(casedata{caseno}.wsspn);
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function hsspnactions()
            switch state
            case 'dataread'
                casedata{caseno}.config.htail=true;
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    casedata{caseno}.hsspn=sspnvalue(casedata{caseno}.hsspn);
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function symflpactions()
            switch state
            case 'dataread'
                casedata{caseno}.highsym=true;
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    symflpvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function asyflpactions()
            switch state
            case 'dataread'
                casedata{caseno}.highasy=true;
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    asyflpvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function contabactions()
            switch state
            case 'dataread'
                casedata{caseno}.highcon=true;
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function tjetactions()
            switch state
            case 'dataread'
                casedata{caseno}.tjet=true;
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    tjetvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function hypersactions()
            switch state
            case 'dataread'
                casedata{caseno}.hypeff=true;
                if(casedata{caseno}.version==1976)
                    if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))
                        hypersvalue();
                    else
                        [line_old,linetype_old,appendflg]=savelinelinetype();
                    end
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function lbactions()
            switch state
            case 'dataread'
                casedata{caseno}.lb=true;
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    lbvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function pwractions()
            switch state
            case 'dataread'
                casedata{caseno}.pwr=true;
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function grndefactions()
            switch state
            case 'dataread'
                casedata{caseno}.grnd=true;
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    grndefvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function fltconactions()
            switch state
            case 'dataread'
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    fltconvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function optinsactions()
            switch state
            case 'dataread'
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    optinsvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function finactions()
            switch state
            case 'dataread'
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    finvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function deflectactions()
            switch state
            case 'dataread'
                if(strcmpi(line(end),'$')||strcmpi(line(end-4:end),'$end'))||(strcmpi(line(end),'&'))
                    deflectvalue();
                else
                    [line_old,linetype_old,appendflg]=savelinelinetype();
                end
            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function unactions()
            switch state
            case 'dataread'

            case 'EOC'

            otherwise
                invaliddataerror();
            end
        end

        function eiactions()
            switch state
            case 'EOI'


                setbuildnumber();


                if strcmp(linetype_old,'end of case')
                    [casedata,caseno]=nextcase(casedata,caseno,casesetup);
                else


                    if((caseno>1)&&casedata{caseno-1}.save)
                        [casedata,caseno]=nextcase(casedata,caseno,casesetup);
                    end
                end
            otherwise


                lostwarning();
            end
        end

        function ieactions()
            switch state
            case 'error'
                error(message('aero:datcomimport:errorInFile',line));
            otherwise


                lostwarning();
            end
        end

    end

    function invaliddataerror()
        error(message('aero:datcomimport:invalidData',line));
    end

    function lostwarning()
        warning(message('aero:datcomimport:algorithmError'));
    end

    function[line_old,linetype_old,appendflg]=savelinelinetype()
        line_old=line;
        linetype_old=linetype;
        appendflg=true;
    end

    function setbuildnumber()

        if(casedata{caseno}.build>1)
            if(casedata{caseno}.version==1976)
                pb=casedata{caseno}.config.body;
                pw=casedata{caseno}.config.wing;
                ph=casedata{caseno}.config.htail;
                pvt=casedata{caseno}.config.vtail;
                pvf=casedata{caseno}.config.vfin;
                pbw=(pb&&pw)||casedata{caseno}.lb;
                pbh=(pb&&ph);
                pbv=(pb&&pvt);
                pbwh=(pbh&&pw);
                pbwv=(pbv&&pw);
                pbwhv=(pbwh&&pvt);
                ppwr=casedata{caseno}.pwr&&pb;
                casedata{caseno}.build=pb+pw+ph+pvt+pvf+pbw+pbh+...
                pbv+pbwh+pbwv+pbwhv+ppwr;
            else
                if~(casedata{caseno}.trim)
                    pb=casedata{caseno}.config.body;
                    pf1=casedata{caseno}.config.fin1.avail;
                    pf2=casedata{caseno}.config.fin2.avail;
                    pf3=casedata{caseno}.config.fin3.avail;
                    pf4=casedata{caseno}.config.fin4.avail;
                    pbf1=(pb&&pf1);
                    pbf1f2=(pbf1&&pf2);
                    pbf1f2f3=(pbf1f2&&pf3);
                    pbf1f2f3f4=(pbf1f2f3&&pf4);
                    casedata{caseno}.build=pb+pf1+pf2+pf3+pf4+pbf1+...
                    pbf1f2+pbf1f2f3+pbf1f2f3f4;
                end
            end
        end
    end

    function[casedata,caseno]=nextcase(casedata,caseno,casesetup)



        if(casedata{caseno}.version==1976)

            if casedata{caseno}.tjet
                casedata{caseno}.highsym=false;
                casedata{caseno}.highasy=false;
                casedata{caseno}.highcon=false;
            end

            if(casedata{caseno}.hypeff)

                casedata{caseno}.highsym=false;
                casedata{caseno}.highasy=false;
                casedata{caseno}.highcon=false;
            end
        end


        if(casedata{caseno}.save==false)
            casedata{caseno+1}=casesetup;
        end

        if(casedata{caseno}.version~=1976)


            casedata{caseno+1}.dim=casedata{caseno}.dim;
            casedata{caseno+1}.deriv=casedata{caseno}.deriv;
            casedata{caseno+1}.hypeff=casedata{caseno}.hypeff;


            casedata{caseno}.alpha=sort(casedata{caseno}.alpha);
            if(casedata{caseno}.nalt>1)
                casedata{caseno}.mach=unique(casedata{caseno}.mach);
                casedata{caseno}.nmach=length(casedata{caseno}.mach);
                casedata{caseno}.alt=unique(casedata{caseno}.alt);
                casedata{caseno}.nalt=length(casedata{caseno}.alt);
            end
            if(casedata{caseno}.rnnub>1)
                [casedata{caseno}.mach,idx]=sort(casedata{caseno}.mach);
                casedata{caseno}.rnnub=casedata{caseno}.rnnub(idx);
            end
        end

        caseno=caseno+1;
    end

    function[eqidx,cidx]=findequalcomma(line)


        eqidx=strfind(line,'=');

        commaidx=strfind(line,',');

        dsign=strfind(line,'$');



        cidx=0;
        for s=1:length(eqidx)
            cidx=[cidx,commaidx(find(commaidx<eqidx(s),1,'last'))];%#ok<AGROW>
        end

        cidx=[cidx,dsign(end)];
    end

    function out=sspnvalue(storedvalue)
        out=storedvalue;

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>
            temp=strtrim(line(cidx(m)+1:eqidx(m)-1));
            if strcmpi(temp(1:end-2),'ssp')
                out=value;
            end
        end
    end

    function symflpvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>

            append=(~strcmpi(line(eqidx(m)-1),')')||~strcmpi(line(eqidx(m)-2),'1'));

            temp=strtrim(line(cidx(m)+1:eqidx(m)-1));
            switch lower(temp(1:end-2))
            case{'delta(','del'}
                casedata{caseno}.delta=collectvalues(append,casedata{caseno}.delta,value);
            case 'ndel'
                casedata{caseno}.ndelta=value;
            end
        end
    end

    function asyflpvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>

            append=(~strcmpi(line(eqidx(m)-1),')')||~strcmpi(line(eqidx(m)-2),'1'));

            if strncmpi(strtrim(line(cidx(m)+1:eqidx(m)-1)),'deltal',6)
                casedata{caseno}.deltal=collectvalues(append,casedata{caseno}.deltal,value);
            elseif strncmpi(strtrim(line(cidx(m)+1:eqidx(m)-1)),'deltar',6)
                casedata{caseno}.deltar=collectvalues(append,casedata{caseno}.deltar,value);
            elseif strcmpi(strtrim(line(cidx(m)+1:eqidx(m)-1)),'ndelta')
                casedata{caseno}.ndelta=value;
            elseif strcmpi(strtrim(line(cidx(m)+1:eqidx(m)-1)),'stype')
                casedata{caseno}.stype=value;
            end
        end
    end

    function tjetvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>
            if strcmpi(strtrim(line(cidx(m)+1:eqidx(m)-1)),'nt')
                casedata{caseno}.nalpha=value;
            end
        end
    end

    function hypersvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>

            append=(~strcmpi(line(eqidx(m)-1),')')||~strcmpi(line(eqidx(m)-2),'1'));

            temp=strtrim(line(cidx(m)+1:eqidx(m)-1));
            switch lower(temp(1:end-2))
            case 'hndl'
                casedata{caseno}.ndelta=value;
            case{'hdelta','hdelta('}
                casedata{caseno}.delta=collectvalues(append,casedata{caseno}.delta,value);
            end
        end
    end

    function grndefvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>
            temp=strtrim(line(cidx(m)+1:eqidx(m)-1));
            switch lower(temp(1:end-2))
            case 'n'
                casedata{caseno}.ngh=value;
            case{'grd','grdht('}
                casedata{caseno}.grndht=value;
            end
        end
    end

    function fltconvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>

            append=(~strcmpi(line(eqidx(m)-1),')')||~strcmpi(line(eqidx(m)-2),'1'));

            temp=strtrim(line(cidx(m)+1:eqidx(m)-1));
            switch lower(temp(1:end-2))
            case 'nma'
                casedata{caseno}.nmach=value;
            case{'mach(','ma'}
                casedata{caseno}.mach=collectvalues(append,casedata{caseno}.mach,value);
            case 'stma'
                casedata{caseno}.stmach=value;
            case 'tsma'
                casedata{caseno}.tsmach=value;
            case 'nalp'
                casedata{caseno}.nalpha=value;
            case{'alschd(','alsc','alpha(','alp'}
                casedata{caseno}.alpha=collectvalues(append,casedata{caseno}.alpha,value);
            case 'na'
                casedata{caseno}.nalt=value;
            case{'alt(','a'}
                casedata{caseno}.alt=collectvalues(append,casedata{caseno}.alt,value);
                if(casedata{caseno}.version~=1976)
                    casedata{caseno}.nalt=length(casedata{caseno}.alt);
                end
            case{'rnnub(','rnn','r'}
                casedata{caseno}.rnnub=collectvalues(append,casedata{caseno}.rnnub,value);
            case 'hype'
                casedata{caseno}.hypers=str2num(lower(strrep(line(eqidx(m)+1:cidx(m+1)-1),'.',' ')));%#ok<ST2NM>
            case 'lo'
                casedata{caseno}.loop=value;
            case 'be'
                casedata{caseno}.beta=value;
                setnolat2007(casedata{caseno}.beta);
            case 'p'
                if strcmpi(temp,'phi')
                    casedata{caseno}.phi=value;
                    setnolat2007(casedata{caseno}.phi);
                end
            end
        end
    end

    function setnolat2007(angle2ck)
        if((casedata{caseno}.version==2007)||(casedata{caseno}.version==2008)||...
            (casedata{caseno}.version==2011)||(casedata{caseno}.version==2014))

            if(abs(angle2ck)>0)
                casedata{caseno}.nolat=true;
            else
                if(casedata{caseno}.nolat_namelist==false)


                    casedata{caseno}.nolat=false;
                end
            end
        end
    end

    function optinsvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2double(line(eqidx(m)+1:cidx(m+1)-1));

            switch lower(strtrim(line(cidx(m)+1:eqidx(m)-1)))
            case 'sref'
                casedata{caseno}.sref=value;
            case{'cbarr','lref'}
                casedata{caseno}.cbar=value;
            case{'blref','latref'}
                casedata{caseno}.blref=value;
            end
        end
    end

    function lbvalue()

        line=strtrim(line(7:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>
            switch lower(strtrim(line(cidx(m)+1:eqidx(m)-1)))
            case 'bb'
                casedata{caseno}.blref=value;
            case 'l'
                casedata{caseno}.cbar=value;
            case 'sref'
                casedata{caseno}.sref=value;
            end
        end
    end

    function finvalue()

        line=strtrim(line(9:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>
            temp=strtrim(line(cidx(m)+1:eqidx(m)-1));
            switch lower(temp(end-2:end))
            case 'nel'
                switch linetype_old



                case 'fin1'
                    casedata{caseno}.config.fin1.npanel=value;
                    if~any(casedata{caseno}.config.fin1.delta)
                        casedata{caseno}.config.fin1.delta=zeros(1,value);
                    end
                case 'fin2'
                    casedata{caseno}.config.fin2.npanel=value;
                    if~any(casedata{caseno}.config.fin2.delta)
                        casedata{caseno}.config.fin2.delta=zeros(1,value);
                    end
                case 'fin3'
                    casedata{caseno}.config.fin3.npanel=value;
                    if~any(casedata{caseno}.config.fin3.delta)
                        casedata{caseno}.config.fin3.delta=zeros(1,value);
                    end
                case 'fin4'
                    casedata{caseno}.config.fin4.npanel=value;
                    if~any(casedata{caseno}.config.fin4.delta)
                        casedata{caseno}.config.fin4.delta=zeros(1,value);
                    end
                end
            end
        end
    end

    function deflectvalue()

        line=strtrim(line(8:end));

        [eqidx,cidx]=findequalcomma(line);

        for m=1:length(eqidx)
            value=str2num(line(eqidx(m)+1:cidx(m+1)-1));%#ok<ST2NM>

            append=~(strcmpi(line(eqidx(m)-2),'A')||strcmpi(line(eqidx(m)-2),'1'));

            temp=strtrim(line(cidx(m)+1:eqidx(m)-1));
            switch lower(temp(1:end-2))
            case 'delta1('
                casedata{caseno}.config.fin1.delta=collectvalues(append,casedata{caseno}.config.fin1.delta,value);
            case 'delta2('
                casedata{caseno}.config.fin2.delta=collectvalues(append,casedata{caseno}.config.fin2.delta,value);
            case 'delta3('
                casedata{caseno}.config.fin3.delta=collectvalues(append,casedata{caseno}.config.fin3.delta,value);
            case 'delta4('
                casedata{caseno}.config.fin4.delta=collectvalues(append,casedata{caseno}.config.fin4.delta,value);
            case 'delt'

                switch lower(temp)
                case 'delta1'
                    casedata{caseno}.config.fin1.delta=collectvalues(append,casedata{caseno}.config.fin1.delta,value);
                case 'delta2'
                    casedata{caseno}.config.fin2.delta=collectvalues(append,casedata{caseno}.config.fin2.delta,value);
                case 'delta3'
                    casedata{caseno}.config.fin3.delta=collectvalues(append,casedata{caseno}.config.fin3.delta,value);
                case 'delta4'
                    casedata{caseno}.config.fin4.delta=collectvalues(append,casedata{caseno}.config.fin4.delta,value);
                end
            end
        end
    end

    function valueout=collectvalues(append,valuein,valuenew)
        if append
            valueout=[valuein,valuenew];
        else
            valueout=valuenew;
        end
    end

    function linetype=outputlinetype()

        linetrim=strtrim(line);

        confightvt={'^WING-BODY-HORIZONTAL'...
        ,'WING-BODY-VERTICAL TAIL-HORIZONTAL TAIL CONFIGURATION'};
        config='CONFIGURATION$';
        warning={'ANALYSIS TERMINATED\>','\<WARNING \*\*\*\>'...
        ,'\<WARNING\*\*\*\>'};
        header={'\<FLIGHT CONDITIONS\>','MOMENT REF. CENTER$'...
        ,'HORIZ      VERT$','DYNAMIC DERIVATIVES \(PER'...
        ,'\<-UNTRIMMED-\>','\<-DERIVATIVE','\<DELTA =\>',' ALPHA$'...
        ,'^ALPHA$','\(DELTAL-DELTAR\)='...
        ,'\<AERODYNAMIC METHODS FOR MISSILE CONFIGURATIONS          PAGE\>'...
        ,'\<PANEL DEFLECTION ANGLES\>','\<X-C.P. MEAS. FROM MOMENT CENTER\>'...
        ,'\<BODY ALONE LINEAR DATA GENERATED FROM\>'...
        ,'\<FLAP DEFLECTION ANGLES\>','\<INCLUDE THE EFFECT\>'};
        auxheader={'^LIFT-CURVE-SLOPE IN'...
        ,'DERIVATIVE INCREMENTALS$'};
        spechead={'\<TIME \(SEC\)','CONTROL FORCE','LOCAL MACH'...
        ,'REYNOLDS NO\. ','LOCAL PRESSURE','DYNAMIC PRESSURE \('...
        ,'BOUNDARY LAYER  ','CONTROL-FORCE ','CORRECTED FORCE'...
        ,'SONIC AMPLIFICATION','AMPLIFICATION FACTOR'...
        ,'VACUUM THRUST','MIN\. PRESSURE','MIN\. JET '...
        ,'JET PRESSURE','MASS-FLOW RATE','PROPELLANT WEIGHT'};
        namelist={'^\$BODY\>'...
        ,'\<N[XT]','\<[XSPR](','\<Z[UL](','\<BNOSE'...
        ,'\<BTAIL','\<BL[NA]=','\<[IFNST]TYPE','\<METHOD'...
        ,'\<\$SYNTHS','\<[XZ]CG','\<[XZ]W','\<ALIW','\<[XZ]H'...
        ,'\<ALIH','\<[XZ]V','\<[XZ]VF','\<SCALE'...
        ,'\<VERTUP','\<HINAX','^\$WGPLNF','^\$HTPLNF','\<TWISTA'...
        ,'\<SSPNDD','\<DHDAD[IO]','\<S[HV]B(','\<SEXT(','\<RLPH('...
        ,'^\$V[TF]PLNF','\<CHRDTP','\<SSPNOP','\<SSPNE'...
        ,'\<SSPN','\<CHRDBP','\<CHRDR','\<SAVS[IO]','\<CHSTAT'...
        ,'\<TYPE','\<SVBW(','\<SVHB(','^\$WGSCHR','\<CLMAXL'...
        ,'\<SLOPE(','\<DWASH','^\$HTSCHR','\<DELTAY','\<CL[ID]','\<ALPHAI'...
        ,'\<CLMAX(','\<CMO','\<CAMBER','\<CMOT','\<CLAMO','\<XAC('...
        ,'\<YCM','^\$V[TF]SCHR','\<[TX]OVC'...
        ,'\<CLALPA(','\<LER[IO]','\<[TX]OVCO','\<TCEFF'...
        ,'\<KSHARP','\<ARCL','\<TYPEIN','\<NPTS','\<XCORD','\<YUPPER'...
        ,'\<YLOWER','\<MEAN','\<THICK','^\$EXPR','\<C[LM]AB('...
        ,'\<C[DLM]B(','\<CLD(','\<C[LM]AW(','\<C[DLM][WH]('...
        ,'\<C[LM]AH(','\<CDV('...
        ,'\<C[LM]AWB(','\<C[DLM]WB(','\<DEODA('...
        ,'\<EPSLION(','\<QOQINF(','\<ALP[OL]W','\<ACLM[WH]','\<CLM[WH]'...
        ,'\<ALP[OL]H','^NAMELIST','^NACA'...
        ,'^DUMP','^PLOT','\<CASEID\>','\<DERIV ','\<DIM ','\<BUILD\>'...
        ,'\<DAMP\>','\<PART\>','\<SAVE\>','\<TRIM\>','\<NEXT CASE\>'...
        ,'\<FORMAT\>','\<INCRMT\>','\<NOGO\>','^\<NO LAT\>$','\<WRITE\>'...
        ,'\<DELETE\>','\<PRESSURES\>','\<PRINT\>','\<SPIN\>'...
        ,'^\$SYMFLP\>','\<DELTA(','\<PHETEP'...
        ,'\<CPRME[IO](','\<CAPINB(','\<CAPOUT(','\<DOBDEF('...
        ,'\<DOBC[IO]T','\<SC[LM]D(','\<C[BCF]=','\<T[CR]='...
        ,'\<JETFLP','\<CMU=','\<DELJET(','\<EFFJET(','^\$ASYFLP\>'...
        ,'\<NDELTA','\<SPANF[IO]','\<PHETE'...
        ,'\<DELTA[LRSD](','\<CHRDF[IO]'...
        ,'\<[XH]SOC(','\<XSPRME','^\$CONTAB'...
        ,'\<CF[IO]TC','\<B[IO]TC','\<CF[IO]TT'...
        ,'\<B[IO]TT','\<B[1234VH]=','\<D[123S]='...
        ,'\<GCMAX','\<KS=','\<RL=','\<BGR=','\<DELR'...
        ,'^\$TVTPAN','\<BVP','\<BDV=','\<SV='...
        ,'\<VPHITE','\<VLP=','\<[ZGY]P=','^\$TRNJET','\<TIME('...
        ,'\<FC(','\<ALPHA(','\<LAMNRJ(','\<SPAN','\<PHE=','\<ME='...
        ,'\<ISP=','\<LFP=','^\$HYPEFF','\<ALITD'...
        ,'\<XHL=','\<TWOTI','\<HNDLTA','\<HDELTA(','\<LAMNR'...
        ,'^\$LARWB','\<SREF','\<DELTEP','\<SFRONT','\<AR='...
        ,'\<R3LEOB','\<L=','\<SWET','\<PERBAS','\<SBASE'...
        ,'\<[ZHB]B=','\<BLF=','\<XCG=','\<THETAD','\<ROUNDN'...
        ,'\<SBS=','\<SBSLB','\<XCENSB','\<XCENW','^\$PROPWR'...
        ,'\<AIETLP','\<NENGSP','\<THSTCP','\<PH[AV]LOC'...
        ,'\<PRPRAD','\<ENGFCT','\<BWAPR','\<NOPBPE','\<BAPR75'...
        ,'\<CROT','^$\JETPWR','\<AIETLJ','\<NENGSJ'...
        ,'\<THSTCJ','\<J[IE]ALOC','\<JE[VL]LOC','\<JINLTA'...
        ,'\<JEANGL','\<AMBTMP','\<JESTMP','\<JETOTP'...
        ,'\<AMBSTP','\<JERAD','^\$GRNDEF','\<NGH','\<GRDHT('...
        ,'\<\$FLTCON','\<NMACH','\<MACH(','\<VINF','\<NALPHA'...
        ,'\<ALSCHD(','\<RNNUB','\<NALT','\<ALT(','\<PINF'...
        ,'\<TINF','\<HYPERS','\<STMACH','\<TSMACH','\<WT='...
        ,'\<GAMMA','\<LOOP','^\$OPTINS','\<ROUGFC'...
        ,'\<CBARR','\<BLREF','\<REFQ\>','\<AXIBOD\>','\<FINSET'...
        ,'\<DERIVATIVES NON-DIMENSIONALIZED\>','Return to main program'};
        dumpcase={...
        'DATA BLOCKS \*\*\*\*$','\<FL[CAP](','\<OPTI(','\<SYNA('...
        ,'\<BDIN(','\<WGIN(','\<[HV]TIN(','\<VFIN(','\<TVT('...
        ,'\<PWIN(','\<LBIN(','\<BODY(','\<WING(','\<[HV]T(','\<VF('...
        ,'\<B[WHV](','\<BW[HV](','\<BWHV(','\<POWR('...
        ,'\<DWSH(','\<[ABCDF](','\<[ABCD]HT(','\<[AD]VF(','\<BD('...
        ,'\<DWA(','\<FACT(','\<[HLW]B('...
        ,'\<PW(','\<SBD(','\<SECD(','\<S[HTW]B(','\<SLAH('...
        ,'\<SL[AG](','\<STBH(','\<ST[GP](','\<TRA('...
        ,'\<TRAH(','\<WBT(','\<FCM(','\<FHG('...
        ,'\<SPR(','\<TCD(','\<TR[MN](','\<TRM2('};
        endline={'\$$','end\$$'};
        if(length(linetrim)<3)
            linetype='blank';

        elseif any(~cellfun('isempty',regexp(linetrim,{...
'\<AUTOMATED STABILITY AND CONTROL METHODS\>'...
            ,'\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 3\/99 \*\*\*\*\*     CASE\>',...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 07\/07 \*\*\*\*\*    CASE\>',...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 08\/08 \*\*\*\*\*    CASE\>',...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 03\/11 \*\*\*\*\*    CASE\>',...
            '\<\*\*\*\*\* THE USAF AUTOMATED MISSILE DATCOM \* REV 2014 \*\*\*\*\*    CASE\>',...
            },'once')))
            linetype='start of run';

        elseif~isempty(regexp(linetrim,'\<END OF JOB\>','once'))
            linetype='end of job';

        elseif~isempty(regexpi(linetrim,['^',casedata{casenoout}.case],'once'))
            linetype='caseid';

        elseif any(~cellfun('isempty',regexp(linetrim,{...
            '\<NA PRINTED','\<NDM PRINTED','\<\*\*\*NOTE\*\*\*'...
            ,'\<\*\*\* NOTE \*\>','\*\*  CD0','\*NOTE\*\>'...
            ,'DEFLECTED CONTROLS','ITS HINGE LINE'...
            ,'NOTE -','APPLICABLE TO','\<VEHICLE WEIGHT'...
            ,'\<LEVEL FLIGHT LIFT COEFFICIENT'},'once')))
            linetype='end of run';

        elseif any(~cellfun('isempty',regexpi(linetrim,{...
'characteristics at angle of attack and in sideslip'...
            ,'\<STATIC AERODYNAMICS FOR\>'...
            ,'\<ALONE STATIC AERODYNAMIC CHARACTERISTICS\>'},'once')))
            linetype='static';

        elseif any(~cellfun('isempty',regexp(linetrim,confightvt,'once')))
            linetype='config';
            casedata{casenoout}.config.downwash=true;
        elseif(~isempty(regexp(linetrim,config,'once'))&&...
            isempty(regexp(linetrim,'\<CASEID\>','once')))
            linetype='config';

        elseif any(~cellfun('isempty',regexp(linetrim,{...
'FT       FT/SEC     LB/FT\*\*2       DEG R'...
            ,'IN       IN/SEC     LB/IN\*\*2       DEG R'...
            ,'M        M/SEC      N/ M\*\*2       DEG K'...
            ,'CM       CM/SEC      N/CM\*\*2       DEG K'},'once')))
            linetype='dimheader';

        elseif~isempty(regexp(linetrim,'MACH NO  =','once'))
            linetype='machheader';

        elseif~isempty(regexp(linetrim,'ALTITUDE =','once'))
            linetype='altitudeheader';

        elseif~isempty(regexp(linetrim,'SIDESLIP = ','once'))
            linetype='sideslipheader';

        elseif~isempty(regexp(linetrim,'REF AREA = ','once'))
            linetype='refareaheader';

        elseif~isempty(regexp(linetrim,'REF LENGTH = ','once'))
            linetype='reflengthheader';

        elseif~isempty(regexp(linetrim,'ALPHA     CD       CL       CM       CN','once'))
            linetype='coeffheader';

        elseif~isempty(regexp(linetrim,'ALPHA       CN        CM        CA            CNA         CMA','once'))
            linetype='finheaderm1';

        elseif~isempty(regexp(linetrim,'ALPHA       CN        CM        CA        CY       CLN       CLL','once'))
            linetype='coeffheaderm1';

        elseif~isempty(regexp(linetrim,'ALPHA       CL        CD      CL/CD     X-C.P.','once'))
            linetype='coeffheaderm2';

        elseif~isempty(regexp(linetrim,'ALPHA       CNA         CMA         CYB         CLNB        CLLB','once'))
            linetype='coeffheaderm3';

        elseif~isempty(regexp(linetrim,'ALPHA     Q/QINF    EPSLON  D\(EPSLON\)/D\(ALPHA\)','once'))
            linetype='epsheader';

        elseif any(~cellfun('isempty',regexp(linetrim,auxheader,'once')))
            linetype='auxheader';

        elseif~isempty(regexp(linetrim,'^XCG RELATIVE TO','once'))
            linetype='auxlemac';

        elseif~isempty(regexp(linetrim,'ALPHA       CLQ          CMQ','once'))
            linetype='dampheader';

        elseif~isempty(regexp(linetrim,'ALPHA       CNQ        CMQ        CAQ       CNAD       CMAD','once'))
            linetype='dampheaderm1';

        elseif~isempty(regexp(linetrim,'ALPHA       CYR       CLNR       CLLR        CYP       CLNP       CLLP','once'))
            linetype='dampheaderm2';

        elseif any(~cellfun('isempty',regexpi(linetrim,{...
'^dynamic derivatives$'...
            ,' DYNAMIC DERIVATIVES$'...
            ,'^BODY \+? \w* \w*? \w*? DYNAMIC DERIVATIVES$'},'once')))
            linetype='dynamic';

        elseif any(~cellfun('isempty',regexp(linetrim,warning,'once')))
            linetype='warning';

        elseif any(~cellfun('isempty',regexp(linetrim,header,'once')))
            linetype='header';

        elseif~isempty(regexpi(linetrim,'ground height= free air'))
            linetype='grndhtfa';

        elseif~isempty(regexpi(linetrim,'ground height= '))
            linetype='grndht';

        elseif~isempty(regexpi(linetrim,'characteristics of high lift and control devices'))
            linetype='highlift';

        elseif~isempty(regexp(linetrim,'DELTA     D\(CL\)     D\(CM\)    D\(CL MAX\)    D\(CD MIN\)','once'))
            linetype='syminchead';

        elseif~isempty(regexpi(linetrim,'induced drag coefficient increment'))
            linetype='symdinchead';

        elseif~isempty(regexp(linetrim,'XS/C        HS/C        DS/C','once'))
            linetype='asymspoilhead';

        elseif~isempty(regexp(linetrim,'XS/C        HS/C        DD/C        DS/C','once'))
            linetype='asymdefhead';

        elseif~isempty(regexp(linetrim,'DS/C         \(CL\)ROLL            CN','once'))
            linetype='asymsspoilhead';

        elseif~isempty(regexp(linetrim,'\<-YAWING MOMENT\>','once'))
            linetype='asymyawhead';


        elseif~isempty(regexp(linetrim,...
            'DELTAL          DELTAR          \(CL\)ROLL','once'))
            linetype='asymclrollhead';

        elseif~isempty(regexp(linetrim,'\<-ROLLING-MOMENT\>','once'))
            linetype='asymrollhead';

        elseif~isempty(regexp(linetrim,'TRIM TAB DEFLECTION','once'))
            linetype='contrimhead';

        elseif~isempty(regexp(linetrim,'STICK FORCE','once'))
            linetype='constickhead';

        elseif~isempty(regexp(linetrim,'TAB FREE','once'))
            linetype='confreehead';

        elseif~isempty(regexp(linetrim,'TAB LOCKED','once'))
            linetype='conlockhead';

        elseif~isempty(regexp(linetrim,'DUE TO GEARING','once'))
            linetype='congearhead';

        elseif~isempty(regexp(linetrim,'D\(CL\)    D\(CL MAX\)     D\(CDI\)','once'))
            linetype='trimhead';

        elseif~isempty(regexp(linetrim,'ALIHT    CD       CL       CM','once'))
            linetype='trimhthead';

        elseif any(~cellfun('isempty',regexp(linetrim,...
            {'ALPHA     CD       CL$','COEFFICIENTS AT TRIM'},'once')))
            linetype='trimhtclcdhead';

        elseif~isempty(regexp(linetrim,'^0   VERTICAL TAIL$','once'))
            linetype='auxvt';

        elseif~isempty(regexp(linetrim,'^0    VENTRAL FIN$','once'))
            linetype='auxvf';

        elseif any(~cellfun('isempty',regexp(linetrim,...
            {'^BASIC BODY PROPERTIES','^WETTED AREA      XCG'},'once')))
            linetype='auxbody';

        elseif any(~cellfun('isempty',regexp(linetrim,...
            {'^BASIC PLANFORM PROPERTIES','^TAPER     ASPECT   QUARTER'...
            ,'^AREA       RATIO      RATIO'},'once')))
            linetype='auxplan';

        elseif~isempty(regexp(linetrim,'^TOTAL THEORITICAL','once'))
            linetype='auxplantt';

        elseif~isempty(regexp(linetrim,'^TOTAL EXPOSED','once'))
            linetype='auxplante';

        elseif~isempty(regexp(linetrim,'^THEORITICAL INBOARD','once'))
            linetype='auxplanti';

        elseif~isempty(regexp(linetrim,'^EXPOSED INBOARD','once'))
            linetype='auxplanei';

        elseif~isempty(regexp(linetrim,'^OUTBOARD','once'))
            linetype='auxplano';

        elseif~isempty(regexp(linetrim,'\<CLA-B\(W\)=\>','once'))
            linetype='auxclab_w';

        elseif~isempty(regexp(linetrim,'\<CLA-B\(H\)=\>','once'))
            linetype='auxclab_ht';

        elseif~isempty(regexp(linetrim,'SIDEWASH, \(','once'))
            linetype='auxside';

        elseif any(~cellfun('isempty',regexp(linetrim,...
            {'^ALPHA         IV-B\(W\)','^2\*PI\*ALPHA\*V\*R'},'once')))
            linetype='auxivhead';

        elseif~isempty(regexp(linetrim,'^CLP\(GAMMA','once'))
            linetype='auxddinc1';

        elseif~isempty(regexp(linetrim,'^CYP/GAMMA','once'))
            linetype='auxddinc2';

        elseif~isempty(regexp(linetrim,'^CLB/GAMMA','once'))
            linetype='auxddinchead';

        elseif any(~cellfun('isempty',regexp(linetrim,{'^ALPHA      \(EPSOLN\)EFF.'...
            ,'^CANARD EFFECTIVE DOWNWASH'},'once')))
            linetype='auxcanardhead';

        elseif any(~cellfun('isempty',regexp(linetrim,{'^0      WING$'...
            ,'WING DATA FAIRING \*\*\*$'},'once')))
            linetype='auxwing';

        elseif any(~cellfun('isempty',regexp(linetrim,...
            {'^0  HORIZONTAL TAIL$'...
            ,'\* HORIZONTAL TAIL DATA FAIRING \*\*\*$'},'once')))
            linetype='auxht';

        elseif~isempty(regexp(linetrim,'WING-BODY DATA FAIRING \*\*\*$','once'))
            linetype='auxwb';

        elseif~isempty(regexp(linetrim,'HORIZONTAL TAIL-BODY DATA FAIRING \*\*\*$','once'))
            linetype='auxbht';

        elseif~isempty(regexp(linetrim,'BODY-WING-HORIZONTAL TAIL DATA FAIRING \*\*\*$','once'))
            linetype='auxbwht';

        elseif~isempty(regexp(linetrim,'^CDL/CL\*\*2','once'))
            linetype='auxcdl';

        elseif~isempty(regexp(linetrim,'^FORCE BREAK MACH NUMBER','once'))
            linetype='auxfmach';

        elseif~isempty(regexp(linetrim,'^MACH\(A\)','once'))
            linetype='auxmacha';

        elseif~isempty(regexp(linetrim,'^\(CLB/CL\)M=0.6','once'))
            linetype='auxclbm';

        elseif~isempty(regexp(linetrim,'^MACH               CL-ALPHA','once'))
            linetype='auxclalp';

        elseif~isempty(regexp(linetrim,'^CLB/CL','once'))
            linetype='auxclb';

        elseif~isempty(regexp(linetrim,'^DRAG DIVERGENCE MA','once'))
            linetype='auxdragd';

        elseif~isempty(regexp(linetrim,'^MACH                 CDO','once'))
            linetype='aux0drag';

        elseif~isempty(regexpi(linetrim,'configuration auxiliary and partial output'))
            linetype='auxpart';

        elseif~isempty(regexpi(linetrim,'special control methods'))
            linetype='speccnt';

        elseif any(~cellfun('isempty',regexp(linetrim,spechead,'once')))
            linetype='spechead';

        elseif~isempty(regexpi(linetrim,'aerodynamic control effectiveness at hypersonic speeds'))
            linetype='hypers';

        elseif~isempty(regexpi(linetrim,'MACH NUMBER='))
            linetype='hypersmach';

        elseif~isempty(regexp(linetrim,'INCREMENT IN NORMAL','once'))
            linetype='hypdfnhead';

        elseif~isempty(regexp(linetrim,'INCREMENT IN AXIAL','once'))
            linetype='hypdfahead';

        elseif~isempty(regexp(linetrim,'MOMENT DUE TO NORMAL','once'))
            linetype='hypcmnhead';

        elseif~isempty(regexp(linetrim,'MOMENT DUE TO AXIAL','once'))
            linetype='hypcmahead';

        elseif~isempty(regexp(linetrim,'LOCATION OF NORMAL','once'))
            linetype='hypcpnhead';

        elseif~isempty(regexp(linetrim,'LOCATION OF AXIAL','once'))
            linetype='hypcpahead';

        elseif any(~cellfun('isempty',regexpi(linetrim,{...
            'wing section definition','defined wing section'})))
            linetype='wingsec';

        elseif any(~cellfun('isempty',regexpi(linetrim,{...
'horizontal tail section definition'...
            ,'defined horizontal tail section'})))
            linetype='htailsec';

        elseif any(~cellfun('isempty',regexpi(linetrim,{...
'vertical tail section definition'...
            ,'defined vertical tail section'})))
            linetype='vtailsec';

        elseif any(~cellfun('isempty',regexpi(linetrim,{...
'ventral fin section definition'...
            ,'defined ventral fin section'})))
            linetype='vfinsec';
        elseif any(~cellfun('isempty',regexpi(linetrim,{...
            'INPUT CARDS','CARDS INPUT'},'once')))
            linetype='end of case';

        elseif(any(~cellfun('isempty',regexpi(linetrim,endline,'once')))||...
            any(~cellfun('isempty',regexp(linetrim,namelist,'once')))||...
            any(~cellfun('isempty',regexp(linetrim,dumpcase,'once'))))
            linetype='namelist';
        else
            linetype=testoutline();
        end

        function linetype=testoutline()

            linetype='unknown';
        end
    end

    function state=outputreaderstate(state)
        if~strcmp(linetype,'blank')

            reading={'static','dynamic','config','caseid'...
            ,'header','highlift','auxpart','speccnt'...
            ,'hypers','wingsec','htailsec','vfinsec'...
            ,'vtailsec','unknown','grndhtfa','grndht'...
            ,'refareaheader','reflengthheader'};
            dataread={'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread','dataread','dataread'...
            ,'dataread','dataread'};

            switch state
            case 'EOI'
                statecell={'lost','SOR','EOJ','namelist','warning'};
                typecell={'start of run','end of job','namelist','warning'};

            case 'EOJ'
                statecell={'lost','EOJ','warning'};
                typecell={'end of job','warning'};

            case 'EOR'
                statecell={'lost','SOR','EOJ','EOR'...
                ,'namelist','EOC','symdincread'...
                ,'warning','dataread'};
                typecell={'start of run','end of job','end of run'...
                ,'namelist','end of case','symdinchead'...
                ,'warning','hypers'};

            case 'SOR'
                statecell=[{'lost'},dataread];
                typecell=reading;

            case 'dataread'
                statecell=[{'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','dimread'...
                ,'coeffheader','dampheader','symincread'...
                ,'asymspoilread','asymsspoilread'...
                ,'asymdefread','asymclrollread'...
                ,'confreeread','congearread','trimread'...
                ,'trimhtread','auxclalpread','dataread'...
                ,'auxlemacread','specread','hypdfnread'...
                ,'hypdfaread','hypcmnread','hypcmaread'...
                ,'hypcpnread','hypcparead','dataread'...
                ,'coeffheaderm1','coeffheaderm2','coeffheaderm3'...
                ,'fltdataread','dampheaderm1','dampheaderm2'...
                ,'finheaderm1'},dataread];
                typecell=[{'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','dimheader'...
                ,'coeffheader','dampheader','syminchead'...
                ,'asymspoilhead','asymsspoilhead'...
                ,'asymdefhead','asymclrollhead'...
                ,'confreehead','congearhead','trimhead'...
                ,'trimhthead','auxclalp','auxheader'...
                ,'auxlemac','spechead','hypdfnhead'...
                ,'hypdfahead','hypcmnhead','hypcmahead'...
                ,'hypcpnhead','hypcpahead','hypersmach'...
                ,'coeffheaderm1','coeffheaderm2','coeffheaderm3'...
                ,'machheader','dampheaderm1','dampheaderm2'...
                ,'finheaderm1'},reading];

            case 'dimread'
                statecell={'lost','fltdataread'};
                typecell={'unknown'};

            case 'fltdataread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'asymyawread'...
                ,'asymrollread','asymclrollread'...
                ,'asymdefread','asymspoilread'...
                ,'asymsspoilread'...
                ,'constickread','conlockread'...
                ,'contrimread','auxbodyread'...
                ,'auxclab_wread','auxclab_htread'...
                ,'auxwingread','auxhtread','dataread'...
                ,'auxlemacread','dataread','fltdataread'...
                ,'dataread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'asymyawhead'...
                ,'asymrollhead','asymclrollhead'...
                ,'asymdefhead','asymspoilhead'...
                ,'asymsspoilhead'...
                ,'constickhead','conlockhead'...
                ,'contrimhead','auxbody'...
                ,'auxclab_w','auxclab_ht'...
                ,'auxwing','auxht','auxheader'...
                ,'auxlemac','header','altitudeheader'...
                ,'sideslipheader'};

            case 'coeffheader'
                statecell={'lost','coeffread'};
                typecell={'unknown'};

            case 'coeffread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','epsread'...
                ,'coeffread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','epsheader'...
                ,'unknown'};

            case 'finheaderm1'
                statecell={'lost','finreadm1'};
                typecell={'unknown'};

            case 'finreadm1'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','finheaderm2'...
                ,'finreadm1'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','coeffheaderm2'...
                ,'unknown'};

            case 'finheaderm2'
                statecell={'lost','finreadm2'};
                typecell={'unknown'};

            case 'finreadm2'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'finreadm2','dataread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'unknown','header'};

            case 'coeffheaderm1'
                statecell={'lost','coeffreadm1'};
                typecell={'unknown'};

            case 'coeffreadm1'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','coeffheaderm2'...
                ,'coeffreadm1'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','coeffheaderm2'...
                ,'unknown'};

            case 'coeffheaderm2'
                statecell={'lost','coeffreadm2'};
                typecell={'unknown'};

            case 'coeffreadm2'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'coeffreadm2','dataread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'unknown','header'};

            case 'coeffheaderm3'
                statecell={'lost','coeffreadm3'};
                typecell={'unknown'};

            case 'coeffreadm3'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'coeffreadm3','dataread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'unknown','header'};

            case 'epsread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','epsread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown'};

            case 'dampheader'
                statecell={'lost','dampread'};
                typecell={'unknown'};

            case 'dampread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','dampread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown'};

            case 'dampheaderm1'
                statecell={'lost','dampreadm1'};
                typecell={'unknown'};

            case 'dampreadm1'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','dampreadm1'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown'};

            case 'dampheaderm2'
                statecell={'lost','dampreadm2'};
                typecell={'unknown'};

            case 'dampreadm2'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','dampreadm2'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown'};

            case 'symincread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'symincread','symincread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'syminchead','unknown'};

            case 'symdincread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'symdincread','symdincread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'header','unknown'};

            case 'asymspoilread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'asymspoilread','asymspoilread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'asymspoilhead','unknown'};

            case 'asymsspoilread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'asymsspoilread','asymsspoilread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'asymsspoilhead','unknown'};

            case 'asymdefread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'asymdefread','asymdefread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'asymdefhead','unknown'};

            case 'asymyawread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'asymyawread','asymclrollread'...
                ,'asymyawread','asymyawread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'asymyawhead','asymclrollhead'...
                ,'header','unknown'};

            case 'asymrollread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'asymrollread','asymrollread'...
                ,'asymrollread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'asymrollhead','header'...
                ,'unknown'};

            case 'asymclrollread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'asymclrollread','asymclrollread'...
                ,'asymclrollread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'asymclrollhead','header'...
                ,'unknown'};

            case 'constickread'
                statecell={'lost','warning','constickread'...
                ,'confreeread','constickread','constickread'};
                typecell={'warning','constickhead'...
                ,'confreehead','header','unknown'};

            case 'confreeread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','confreeread'...
                ,'confreeread','confreeread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','confreehead'...
                ,'header','unknown'};

            case 'conlockread'
                statecell={'lost','warning','conlockread'...
                ,'congearread','conlockread','conlockread'};
                typecell={'warning','conlockhead'...
                ,'congearhead','header','unknown'};

            case 'congearread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','congearread'...
                ,'congearread','congearread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','congearhead'...
                ,'header','unknown'};

            case 'contrimread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','contrimread'...
                ,'contrimread','contrimread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','contrimhead'...
                ,'header','unknown'};

            case 'trimread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','trimread','dataread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown','header'};

            case 'trimhtread'
                statecell={'lost','trimhtread','trimhtclcdread'};
                typecell={'unknown','trimhtclcdhead'};

            case 'trimhtclcdread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','trimhtclcdread'...
                ,'trimhtclcdread','dataread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','trimhtclcdhead'...
                ,'unknown','header'};

            case 'auxbodyread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxbodyread'...
                ,'auxlemacread','auxbodyread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','auxbody'...
                ,'auxlemac','unknown'};

            case 'auxlemacread'
                statecell={'lost','auxplanread'};
                typecell={'auxplan'};

            case 'auxplanread'
                statecell={'lost','auxplanread','auxvtread'...
                ,'auxvfread','auxwingread','auxhtread'};
                typecell={'auxplan','auxvt'...
                ,'auxvf','auxwing','auxht'};

            case 'auxvtread'
                statecell={'lost','auxplantiread','auxplanttread'};
                typecell={'auxplanti','auxplantt'};
                state_old='auxvtread';

            case 'auxvfread'
                statecell={'lost','auxplantiread','auxplanttread'};
                typecell={'auxplanti','auxplantt'};
                state_old='auxvfread';

            case 'auxplantiread'
                statecell={'lost','auxplantiread','auxplaneiread'};
                typecell={'unknown','auxplanei'};

            case 'auxplaneiread'
                statecell={'lost','auxplaneiread','auxplanoread'};
                typecell={'unknown','auxplano'};

            case 'auxplanoread'
                statecell={'lost','auxplanoread','auxplanttread'};
                typecell={'unknown','auxplantt'};

            case 'auxplanttread'
                statecell={'lost','auxplanttread','auxplanteread'};
                typecell={'unknown','auxplante'};

            case 'auxplanteread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxvtread'...
                ,'auxhtread','auxvfread','auxplanteread'...
                ,'auxplanttread','auxplantiread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','auxvt'...
                ,'auxht','auxvf','unknown'...
                ,'auxplantt','auxplanti'};

            case 'auxclab_wread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxclab_htread'...
                ,'auxclab_wread','auxsideread','auxivread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','auxclab_ht'...
                ,'auxclab_w','auxside','auxivhead'};

            case 'auxclab_htread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'auxivread','auxclab_htread','auxcanardread'...
                ,'auxsideread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'auxivhead','auxclab_ht','auxcanardhead'...
                ,'auxside'};

            case 'auxsideread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxcanardread'...
                ,'auxivread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','auxcanardhead'...
                ,'auxivhead'};

            case 'auxivread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxivread'...
                ,'auxivread','auxivread','auxddinc1read'...
                ,'auxcanardread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','auxheader'...
                ,'auxivhead','unknown','auxddinc1'...
                ,'auxcanardhead'};

            case 'auxddinc1read'
                statecell={'lost','warning','auxddinc2read'};
                typecell={'warning','auxddinc2'};

            case 'auxddinc2read'
                statecell={'lost','warning','auxddincread'};
                typecell={'warning','auxddinchead'};

            case 'auxddincread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxddincread'...
                ,'auxcanardread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown'...
                ,'auxcanardhead'};

            case 'auxcanardread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning'...
                ,'auxcanardread','auxcanardread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning'...
                ,'unknown','auxcanardhead'};

            case 'auxwingread'
                statecell={'lost','auxcdlread'...
                ,'auxplantiread','auxplanttread'};
                typecell={'auxcdl'...
                ,'auxplanti','auxplantt'};
                state_old='auxwingread';

            case 'auxwbread'
                statecell={'lost','auxclbread'};
                typecell={'auxclb'};
                state_old='auxwbread';

            case 'auxhtread'
                statecell={'lost','auxcdlread'...
                ,'auxplantiread','auxplanttread'};
                typecell={'auxcdl'...
                ,'auxplanti','auxplantt'};
                state_old='auxhtread';

            case 'auxbhtread'
                statecell={'lost','auxclbread'};
                typecell={'auxclb'};
                state_old='auxbhtread';

            case 'auxbwhtread'
                statecell={'lost','auxdragdread'};
                typecell={'auxdragd'};
                state_old='';

            case 'auxcdlread'
                statecell={'lost','auxfmachread'};
                typecell={'auxfmach'};

            case 'auxfmachread'
                statecell={'lost','auxmacharead'};
                typecell={'auxmacha'};

            case 'auxmacharead'
                statecell={'lost','auxclbmread'};
                typecell={'auxclbm'};

            case 'auxclbmread'
                statecell={'lost','dataread'};
                typecell={'auxheader'};

            case 'auxclalpread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxclalpread','auxwbread'...
                ,'auxbhtread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown','auxwb'...
                ,'auxbht'};

            case 'auxclbread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','auxhtread','auxbwhtread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','auxht','auxbwht'};

            case 'auxdragdread'
                statecell={'lost','aux0dragread'};
                typecell={'aux0drag'};

            case 'aux0dragread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','aux0dragread'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','unknown'};

            case 'hypdfnread'
                statecell={'lost','hypdfaread','hypdfnread'...
                ,'hypdfnread'};
                typecell={'hypdfahead','header'...
                ,'unknown'};

            case 'hypdfaread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'warning','hypdfaread','hypdfaread'};
                typecell={'start of run','end of run','namelist'...
                ,'warning','header','unknown'};

            case 'hypcmnread'
                statecell={'lost','hypcmaread','hypcmnread'...
                ,'hypcmnread'};
                typecell={'hypcmahead','header'...
                ,'unknown'};

            case 'hypcmaread'
                statecell={'lost','SOR','EOR','namelist'...
                ,'warning','hypcmaread','hypcmaread'};
                typecell={'start of run','end of run','namelist'...
                ,'warning','header','unknown'};

            case 'hypcpnread'
                statecell={'lost','hypcparead','hypcpnread'...
                ,'hypcpnread'};
                typecell={'hypcpahead','header'...
                ,'unknown'};

            case 'hypcparead'
                statecell={'lost','SOR','EOR','namelist'...
                ,'EOC','EOJ','warning','hypcparead'...
                ,'hypcparead'};
                typecell={'start of run','end of run','namelist'...
                ,'end of case','end of job','warning','header'...
                ,'unknown'};

            case 'specread'
                statecell={'lost','SOR','namelist','EOC'...
                ,'EOJ','specread'};
                typecell={'start of run','namelist','end of case'...
                ,'end of job','spechead'};

            case 'EOC'
                statecell={'lost','EOJ','namelist','warning'};
                typecell={'end of job','namelist','warning'};

            case 'namelist'
                statecell={'lost','SOR','EOJ','namelist'...
                ,'EOC','warning','dataread','dataread'};
                typecell={'start of run','end of job','namelist'...
                ,'end of case','warning','header','unknown'};

            case 'warning'
                statecell={'lost','SOR','EOJ'...
                ,'EOC','warning','dataread'};
                typecell={'start of run','end of job'...
                ,'end of case','warning','unknown'};

            otherwise
                statecell={'lost','lost'};
                typecell={' '};
            end
            stateidx=find(strcmp(typecell,linetype));
            if isempty(stateidx)
                stateidx=0;
            end
            state=statecell{stateidx+1};
        end
    end

    function getoutputdata()
        persistent idxm idxa idxgh cnt sgcnt wcnt htcnt vtcnt vfcnt

        switch linetype
        case 'blank'

        case 'static'

            staticinit()
        case 'dynamic'

            dynamicinit()
        case 'config'

            configinit()
        case 'caseid'


        case 'header'






        case 'refareaheader'

            if isempty(casedata{casenoout}.sref)
                casedata{casenoout}.sref=str2double(line(17:26));
            end
        case 'reflengthheader'

            if isempty(casedata{casenoout}.cbar)
                casedata{casenoout}.cbar=str2double(line(19:26));
            end
            if isempty(casedata{casenoout}.blref)
                casedata{casenoout}.blref=str2double(line(57:65));
            end
        case 'sideslipheader'

        case 'altitudeheader'
            readDatcomData()
        case 'machheader'
            readDatcomData()
        case 'grndhtfa'

            idxgh=casedata{casenoout}.ngh+1;
        case 'grndht'

            idxgh=find(round(convlength(casedata{casenoout}.grndht,casedata{casenoout}.dim,'ft')*100)/100==str2double(line(100:106)));
        case 'dimheader'


        case{'coeffheader','coeffheaderm1','coeffheaderm2','coeffheaderm3','finheaderm1','finheaderm2'}







        case 'epsheader'


        case{'dampheader','dampheaderm1','dampheaderm2'}




        case 'auxheader'


        case 'syminchead'


        case 'symdinchead'


        case 'asymspoilhead'


        case 'asymsspoilhead'


        case 'asymdefhead'


        case 'asymyawhead'


        case 'asymrollhead'


        case 'asymclrollhead'


        case 'constickhead'

            cnt=1;
        case 'confreehead'

            cnt=1;
        case 'conlockhead'

            cnt=1;
        case 'congearhead'

            cnt=1;
        case 'contrimhead'

            cnt=1;
        case 'trimhead'

            triminit()
        case 'trimhthead'

            trimhtinit()
        case 'trimhtclcdhead'

            trimhtclcdinit()
        case 'auxvt'


        case 'auxvf'


        case 'auxbody'

            auxbodyinit()
        case 'auxplan'


        case 'auxplantt'

            auxplanttinit();
        case 'auxplante'

            auxplanteinit();
        case 'auxplanti'

            auxplantiinit();
        case 'auxplanei'

            auxplaneiinit();
        case 'auxplano'

            auxplanoinit();
        case 'auxlemac'

            auxlemacinitread()
        case 'auxclab_w'

            auxclab_winitread()
        case 'auxclab_ht'

            auxclab_htinitread()
        case 'auxside'

            auxsideinitread()
        case 'auxivhead'

            auxivinit()
        case 'auxddinc1'

            auxddinc1initread()
        case 'auxddinc2'

            auxddinc2initread()
        case 'auxddinchead'

            auxddincinit()
        case 'auxcanardhead'

            auxcanardinit()
        case 'auxwing'


        case 'auxwb'

            cnt=1;
        case 'auxht'


        case 'auxbht'

            cnt=1;
        case 'auxbwht'


        case 'auxcdl'

            auxcdlinitread();
        case 'auxfmach'

            auxfmachinitread();
        case 'auxmacha'

            auxmachainitread();
        case 'auxclbm'

            auxclbminitread();
        case 'auxclalp'

            auxclalpinit();
        case 'auxclb'

            auxclbinitread();
        case 'auxdragd'

            auxdragdinitread()
        case 'aux0drag'

            aux0draginit()
        case 'hypersmach'

            idxm=find(casedata{casenoout}.mach==str2double(line(33:37)));
        case 'hypdfnhead'


        case 'hypdfahead'


        case 'hypcmnhead'


        case 'hypcmahead'


        case 'hypcpnhead'


        case 'hypcpahead'


        case 'spechead'

            specread()
        case 'highlift'

            highliftinit()
        case 'auxpart'


        case 'speccnt'

            specinit()
        case 'hypers'

            hypersinit()
        case 'wingsec'




        case 'htailsec'




        case 'vtailsec'




        case 'vfinsec'




        case 'unknown'
            readDatcomData()

        case 'start of run'

            cnt=1;
            wcnt=1;
            htcnt=1;
            vtcnt=1;
            vfcnt=1;

        case 'end of job'


            if strcmp(state_old,'EOC')
                casenoout=casenoout-1;
            end

        case 'end of run'



        case 'end of case'

            casenoout=casenoout+1;
            state_old='EOC';

        case 'namelist'

            state_old='';

        case 'warning'

            state_old='';

        otherwise

            lostwarning();
        end

        function readDatcomData()
            persistent temp
            switch state
            case 'dataread'

            case 'fltdataread'
                fltdataread()
            case{'coeffread','coeffreadm1','coeffreadm2','coeffreadm3','finreadm1','finreadm2'}

                staticread()
            case 'epsread'
                configread()
            case{'dampread','dampreadm1','dampreadm2'}

                dynamicread()
            case 'symincread'

                replacenandm()
                idxdel=find(casedata{casenoout}.delta==str2double(line(7:11)));
                casedata{casenoout}.dcl_sym(idxdel,idxm,idxa)=getcoeffs(line(16:21));
                casedata{casenoout}.dcm_sym(idxdel,idxm,idxa)=getcoeffs(line(26:32));
                casedata{casenoout}.dclmax_sym(idxdel,idxm,idxa)=getcoeffs(line(37:42));
                casedata{casenoout}.dcdmin_sym(idxdel,idxm,idxa)=getcoeffs(line(48:55));
                casedata{casenoout}.clad_sym(idxdel,idxm,idxa)=getcoeffs(line(71:80));
                casedata{casenoout}.cha_sym(idxdel,idxm,idxa)=getcoeffs(line(83:92));
                casedata{casenoout}.chd_sym(idxdel,idxm,idxa)=getcoeffs(line(95:end));
            case 'symdincread'

                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(4:8)));
                casedata{casenoout}.dcdi_sym(idxaph,:,idxm,idxa)=getcoeffs(line(16:end));
            case 'asymspoilread'

                replacenandm()
                idxdel=cnt;
                casedata{casenoout}.xsc(idxdel,idxm,idxa)=getcoeffs(line(34:40));
                casedata{casenoout}.hsc(idxdel,idxm,idxa)=getcoeffs(line(46:52));
                casedata{casenoout}.dsc(idxdel,idxm,idxa)=getcoeffs(line(58:64));
                casedata{casenoout}.clroll(idxdel,idxm,idxa)=getcoeffs(line(70:80));
                casedata{casenoout}.cn_asy(idxdel,idxm,idxa)=getcoeffs(line(86:end));
                cnt=cnt+1;
            case 'asymsspoilread'
                replacenandm()
                idxdel=cnt;

                casedata{casenoout}.dsc(idxdel,idxm,idxa)=getcoeffs(line(46:52));
                casedata{casenoout}.clroll(idxdel,idxm,idxa)=getcoeffs(line(59:69));
                casedata{casenoout}.cn_asy(idxdel,idxm,idxa)=getcoeffs(line(76:end));
                cnt=cnt+1;
            case 'asymdefread'

                replacenandm()
                idxdel=cnt;
                casedata{casenoout}.xsc(idxdel,idxm,idxa)=getcoeffs(line(29:35));
                casedata{casenoout}.hsc(idxdel,idxm,idxa)=getcoeffs(line(41:47));
                casedata{casenoout}.ddc(idxdel,idxm,idxa)=getcoeffs(line(53:59));
                casedata{casenoout}.dsc(idxdel,idxm,idxa)=getcoeffs(line(65:71));
                casedata{casenoout}.clroll(idxdel,idxm,idxa)=getcoeffs(line(77:87));
                casedata{casenoout}.cn_asy(idxdel,idxm,idxa)=getcoeffs(line(93:end));
                cnt=cnt+1;
            case 'asymyawread'

                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(2:6)));
                casedata{casenoout}.cn_asy(idxaph,:,idxm,idxa)=getcoeffs(line(15:end));
            case 'asymrollread'

                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(2:6)));
                casedata{casenoout}.clroll(idxaph,:,idxm,idxa)=getcoeffs(line(15:end));
            case 'asymclrollread'


                replacenandm()
                idxdel=find(casedata{casenoout}.deltal==str2double(line(46:50)));
                casedata{casenoout}.clroll(idxdel,idxm,idxa)=getcoeffs(line(77:end));
            case 'constickread'

                replacenandm()

                casedata{casenoout}.fc_con(:,:,idxm,idxa)=contabreadfix(casedata{casenoout}.fc_con(:,:,idxm,idxa));
                cnt=cnt+1;
            case 'confreeread'

                replacenandm()

                casedata{casenoout}.fhmcoeff_free(:,:,idxm,idxa)=contabreadfix(casedata{casenoout}.fhmcoeff_free(:,:,idxm,idxa));
                cnt=cnt+1;
            case 'conlockread'

                replacenandm()

                casedata{casenoout}.fhmcoeff_lock(:,:,idxm,idxa)=contabreadfix(casedata{casenoout}.fhmcoeff_lock(:,:,idxm,idxa));
                cnt=cnt+1;
            case 'congearread'

                replacenandm()

                casedata{casenoout}.fhmcoeff_gear(:,:,idxm,idxa)=contabreadfix(casedata{casenoout}.fhmcoeff_gear(:,:,idxm,idxa));
                cnt=cnt+1;
            case 'contrimread'

                replacenandm()

                casedata{casenoout}.ttab_def(:,:,idxm,idxa)=contabreadfix(casedata{casenoout}.ttab_def(:,:,idxm,idxa));
                cnt=cnt+1;
            case 'trimread'
                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(6:10)));
                casedata{casenoout}.cl_utrim(idxaph,idxm,idxa)=getcoeffs(line(14:19));
                casedata{casenoout}.cd_utrim(idxaph,idxm,idxa)=getcoeffs(line(24:29));
                casedata{casenoout}.cm_utrim(idxaph,idxm,idxa)=getcoeffs(line(33:39));
                casedata{casenoout}.delt_trim(idxaph,idxm,idxa)=getcoeffs(line(43:47));
                casedata{casenoout}.dcl_trim(idxaph,idxm,idxa)=getcoeffs(line(51:56));
                casedata{casenoout}.dclmax_trim(idxaph,idxm,idxa)=getcoeffs(line(62:67));
                casedata{casenoout}.dcdi_trim(idxaph,idxm,idxa)=getcoeffs(line(73:81));
                casedata{casenoout}.dcdmin_trim(idxaph,idxm,idxa)=getcoeffs(line(84:91));
                casedata{casenoout}.cha_trim(idxaph,idxm,idxa)=getcoeffs(line(95:104));
                casedata{casenoout}.chd_trim(idxaph,idxm,idxa)=getcoeffs(line(108:end));

            case 'trimhtread'
                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(3:7)));
                casedata{casenoout}.cl_tailutrim(idxaph,idxm,idxa)=getcoeffs(line(11:16));
                casedata{casenoout}.cd_tailutrim(idxaph,idxm,idxa)=getcoeffs(line(20:25));
                casedata{casenoout}.cm_tailutrim(idxaph,idxm,idxa)=getcoeffs(line(29:35));
                casedata{casenoout}.hm_tailutrim(idxaph,idxm,idxa)=getcoeffs(line(38:47));
                casedata{casenoout}.aliht_tailtrim(idxaph,idxm,idxa)=getcoeffs(line(83:87));
                casedata{casenoout}.cl_tailtrim(idxaph,idxm,idxa)=getcoeffs(line(90:95));
                casedata{casenoout}.cd_tailtrim(idxaph,idxm,idxa)=getcoeffs(line(99:104));
                casedata{casenoout}.cm_tailtrim(idxaph,idxm,idxa)=getcoeffs(line(108:114));
                casedata{casenoout}.hm_tailtrim(idxaph,idxm,idxa)=getcoeffs(line(117:end));

            case 'trimhtclcdread'
                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(54:58)));
                casedata{casenoout}.cl_trimi(idxaph,idxm,idxa)=getcoeffs(line(62:67));
                casedata{casenoout}.cd_trimi(idxaph,idxm,idxa)=getcoeffs(line(71:end));

            case 'auxbodyread'
                idxrun=cnt;

                replacenandm()
                casedata{casenoout}.wetarea_b(idxm,idxa,idxrun)=getcoeffs(line(13:23));
                casedata{casenoout}.xcg_b(idxm,idxa,idxrun)=getcoeffs(line(28:32));
                casedata{casenoout}.zcg_b(idxm,idxa,idxrun)=getcoeffs(line(36:40));
                casedata{casenoout}.basearea_b(idxm,idxa,idxrun)=getcoeffs(line(47:53));
                casedata{casenoout}.cd0_b(idxm,idxa,idxrun)=getcoeffs(line(61:71));
                casedata{casenoout}.basedrag_b(idxm,idxa,idxrun)=getcoeffs(line(75:85));
                casedata{casenoout}.fricdrag_b(idxm,idxa,idxrun)=getcoeffs(line(89:99));
                casedata{casenoout}.presdrag_b(idxm,idxa,idxrun)=getcoeffs(line(105:end));
                cnt=cnt+1;

            case 'auxplanttread'
                replacenandm()
                auxplanttread();

            case 'auxplanteread'
                replacenandm()
                auxplanteread();

            case 'auxplantiread'
                replacenandm()
                auxplantiread();

            case 'auxplaneiread'
                replacenandm()
                auxplaneiread();

            case 'auxplanoread'
                replacenandm()
                auxplanoread();

            case 'auxivread'
                replacenandm()
                auxivread();

            case 'auxddincread'
                replacenandm()
                casedata{casenoout}.clbgamma(idxm,idxa)=getcoeffs(line(46:56));
                casedata{casenoout}.cmothetaw(idxm,idxa)=getcoeffs(line(64:74));
                casedata{casenoout}.cmothetah(idxm,idxa)=getcoeffs(line(82:end));


            case 'auxcanardread'
                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(46:53)));
                casedata{casenoout}.espeff(idxaph,idxm,idxa)=getcoeffs(line(61:71));
                casedata{casenoout}.despdalpeff(idxaph,idxm,idxa)=getcoeffs(line(79:end));

            case 'auxclalpread'
                replacenandm()
                auxclalpread()

            case 'aux0dragread'

                replacenandm()
                casedata{casenoout}.cd0mach(cnt,idxm,idxa)=getcoeffs(line(53:58));
                casedata{casenoout}.cd0(cnt,idxm,idxa)=getcoeffs(line(73:end));
                cnt=cnt+1;

            case 'hypdfnread'

                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(4:8)));
                casedata{casenoout}.df_normal(idxaph,:,idxm)=getcoeffs(line(16:end));

            case 'hypdfaread'

                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(4:8)));
                casedata{casenoout}.df_axial(idxaph,:,idxm)=getcoeffs(line(16:end));

            case 'hypcmnread'

                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(4:8)));
                casedata{casenoout}.cm_normal(idxaph,:,idxm)=getcoeffs(line(16:end));

            case 'hypcmaread'

                replacenandm()
                idxaph=find(casedata{casenoout}.alpha==str2double(line(4:8)));
                casedata{casenoout}.cm_axial(idxaph,:,idxm)=getcoeffs(line(16:end));

            case 'hypcpnread'

                replacenandm()
                hypcpnread()
            case 'hypcparead'

                replacenandm()
                hypcparead()
            end

            function output=contabreadfix(in)

                output=in;
                end_cnt=ceil(casedata{casenoout}.nalpha*casedata{casenoout}.ndelta/11);
                if(cnt==1)
                    temp=getcoeffs(line(4:end));
                elseif(cnt<end_cnt)
                    temp=[temp,getcoeffs(line(4:end))];
                else
                    temp=[temp,getcoeffs(line(4:end))];
                    output=reshape(temp,casedata{casenoout}.ndelta,casedata{casenoout}.nalpha)';
                end
            end
        end

        function fltdataread()
            idxa=1;
            if(casedata{casenoout}.version==1976)
                mach=str2double(line(3:8));
                alt=str2num(line(10:19));%#ok<ST2NM>
                idxm=find(casedata{casenoout}.mach==mach);
                if((casedata{casenoout}.loop~=1)||...
                    (casedata{casenoout}.nalt>0))
                    idxa=find(casedata{casenoout}.alt==alt);
                end
            else
                if strcmpi(linetype,'machheader')
                    mach=str2double(line(22:26));
                    idxm=find(casedata{casenoout}.mach==mach);
                end
                if(strcmpi(linetype,'altitudeheader')&&(casedata{casenoout}.nalt>0))
                    alt=str2double(line(16:26));
                    idxa=find(casedata{casenoout}.alt==alt);
                end
            end

            if(sbuild>casedata{casenoout}.build)
                sbuild=1;
                scnt=1;
            end
            if(dbuild>casedata{casenoout}.build)||...
                ((casedata{casenoout}.version~=1976)&&...
                (dbuild>(casedata{casenoout}.build-...
                casedata{casenoout}.config.fin1.avail-...
                casedata{casenoout}.config.fin2.avail-...
                casedata{casenoout}.config.fin3.avail-...
                casedata{casenoout}.config.fin4.avail)))
                dbuild=1;
                dcnt=1;
            end
        end

        function staticinit()
            if~isfield(casedata{casenoout},'cd')
                nalpha=casedata{casenoout}.nalpha;
                [nmach,nalt]=getnmachnalt();
                nbuild=casedata{casenoout}.build;
                ngh=casedata{casenoout}.ngh;
                ndelta=1;

                if(casedata{casenoout}.version==1976)
                    if(((casedata{casenoout}.highsym==1)||(casedata{casenoout}.highasy==1))...
                        &&(casedata{casenoout}.ngh>0))
                        ndelta=casedata{casenoout}.ndelta;
                    end
                end

                idxgh=1;
                sgcnt=1;

                casedata{casenoout}.cd=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.cl=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.cm=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.cn=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.ca=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.xcp=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.cma=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.cyb=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.cnb=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.clb=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                if(casedata{casenoout}.version==1976)
                    casedata{casenoout}.cla=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                end
                if(casedata{casenoout}.version~=1976)
                    casedata{casenoout}.cna=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                    casedata{casenoout}.clod=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                    casedata{casenoout}.cy=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                    casedata{casenoout}.cln=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                    casedata{casenoout}.cll=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                end
            end
        end

        function staticread()

            nalpha=casedata{casenoout}.nalpha;

            replacenandm()
            if(casedata{casenoout}.version==1976)
                if((casedata{casenoout}.ngh>0)&&...
                    ((casedata{casenoout}.highsym==1)||(casedata{casenoout}.highasy==1))&&...
                    (sbuild>casedata{casenoout}.build))

                    sbuild=1;
                end
                if((casedata{casenoout}.ngh>0)&&...
                    ((casedata{casenoout}.highsym==1)||(casedata{casenoout}.highasy==1))&&...
                    (sgcnt>casedata{casenoout}.ndelta))

                    sgcnt=1;
                end

                idxaph=find(casedata{casenoout}.alpha==str2double(line(3:7)));
                idxdel=sgcnt;
                casedata{casenoout}.cd(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(11:16));
                casedata{casenoout}.cl(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(20:25));
                casedata{casenoout}.cm(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(29:35));
                casedata{casenoout}.cn(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(38:43));
                casedata{casenoout}.ca(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(47:52));
                casedata{casenoout}.xcp(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(56:61));
                casedata{casenoout}.cla(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(65:74));
                casedata{casenoout}.cma(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(78:87));
                casedata{casenoout}.cyb(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(91:100));
                casedata{casenoout}.cnb(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(104:113));
                casedata{casenoout}.clb(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(117:end));

                if(casedata{casenoout}.build>1)
                    scnt=scnt+1;
                    if((scnt>nalpha)&&(sbuild<=casedata{casenoout}.build))
                        sbuild=sbuild+1;
                        scnt=1;
                    end
                    if((idxgh==casedata{casenoout}.ngh)&&...
                        ((casedata{casenoout}.highsym==1)||(casedata{casenoout}.highasy==1))&&...
                        (sbuild>casedata{casenoout}.build))
                        sgcnt=sgcnt+1;
                    end
                else
                    if((idxgh==casedata{casenoout}.ngh)&&...
                        ((casedata{casenoout}.highsym==1)||(casedata{casenoout}.highasy==1)))
                        sgcnt=sgcnt+1;
                    end
                end
            else
                idxaph=find(casedata{casenoout}.alpha==str2double(line(5:14)));
                idxdel=1;
                switch state
                case 'coeffreadm1'
                    casedata{casenoout}.cn(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(15:24));
                    casedata{casenoout}.cm(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(25:35));
                    casedata{casenoout}.ca(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(35:44));
                    casedata{casenoout}.cy(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(45:54));
                    casedata{casenoout}.cln(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(55:64));
                    casedata{casenoout}.cll(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(65:74));
                case 'coeffreadm2'
                    casedata{casenoout}.cl(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(15:24));
                    casedata{casenoout}.cd(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(25:35));
                    casedata{casenoout}.clod(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(35:44));
                    casedata{casenoout}.xcp(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(45:54));
                case 'coeffreadm3'
                    casedata{casenoout}.cna(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(15:26));
                    casedata{casenoout}.cma(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(27:38));
                    if(casedata{casenoout}.nolat==false)
                        casedata{casenoout}.cyb(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(39:50));
                        casedata{casenoout}.cnb(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(51:62));
                        casedata{casenoout}.clb(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(63:74));
                    end


                    if(casedata{casenoout}.build>1)
                        scnt=scnt+1;
                        if((scnt>nalpha)&&(sbuild<=casedata{casenoout}.build))
                            sbuild=sbuild+1;
                            scnt=1;
                        end
                    end
                case 'finreadm1'
                    casedata{casenoout}.cn(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(15:24));
                    casedata{casenoout}.cm(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(25:35));
                    casedata{casenoout}.ca(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(35:44));
                    casedata{casenoout}.cna(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(49:60));
                    casedata{casenoout}.cma(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(61:72));
                case 'finreadm2'
                    casedata{casenoout}.cl(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(15:24));
                    casedata{casenoout}.cd(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(25:34));
                    casedata{casenoout}.clod(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(35:44));
                    casedata{casenoout}.xcp(idxaph,idxm,idxa,sbuild,idxgh,idxdel)=getcoeffs(line(45:54));


                    if(casedata{casenoout}.build>1)
                        scnt=scnt+1;
                        if((scnt>nalpha)&&(sbuild<=casedata{casenoout}.build))
                            sbuild=sbuild+1;
                            scnt=1;
                        end
                    end
                end
            end

        end

        function dynamicinit()
            if~isfield(casedata{casenoout},'cmad')
                nalpha=casedata{casenoout}.nalpha;
                [nmach,nalt]=getnmachnalt();

                if(casedata{casenoout}.version==1976)
                    nbuild=casedata{casenoout}.build;
                    casedata{casenoout}.clq=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cmq=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.clad=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cmad=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.clp=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cyp=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cnp=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cnr=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.clr=99999*ones(nalpha,nmach,nalt,nbuild);
                else
                    nbuild=casedata{casenoout}.build-...
                    (casedata{casenoout}.build>1)*...
                    (casedata{casenoout}.config.fin1.avail+...
                    casedata{casenoout}.config.fin2.avail+...
                    casedata{casenoout}.config.fin3.avail+...
                    casedata{casenoout}.config.fin4.avail);
                    casedata{casenoout}.cmq=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cnq=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.caq=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cmad=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cnad=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.clp=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cyp=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cnp=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.clr=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cyr=99999*ones(nalpha,nmach,nalt,nbuild);
                    casedata{casenoout}.cnr=99999*ones(nalpha,nmach,nalt,nbuild);
                end
            end
        end

        function dynamicread()
            nalpha=casedata{casenoout}.nalpha;
            replacenandm()

            if(casedata{casenoout}.version==1976)
                idxaph=find(casedata{casenoout}.alpha==str2double(line(3:9)));
                casedata{casenoout}.clq(idxaph,idxm,idxa,dbuild)=getcoeffs(line(13:22));
                casedata{casenoout}.cmq(idxaph,idxm,idxa,dbuild)=getcoeffs(line(26:35));
                casedata{casenoout}.clad(idxaph,idxm,idxa,dbuild)=getcoeffs(line(40:49));
                casedata{casenoout}.cmad(idxaph,idxm,idxa,dbuild)=getcoeffs(line(53:62));
                casedata{casenoout}.clp(idxaph,idxm,idxa,dbuild)=getcoeffs(line(66:75));
                casedata{casenoout}.cyp(idxaph,idxm,idxa,dbuild)=getcoeffs(line(79:88));
                casedata{casenoout}.cnp(idxaph,idxm,idxa,dbuild)=getcoeffs(line(92:101));
                casedata{casenoout}.cnr(idxaph,idxm,idxa,dbuild)=getcoeffs(line(105:114));
                casedata{casenoout}.clr(idxaph,idxm,idxa,dbuild)=getcoeffs(line(118:end));
                if(casedata{casenoout}.build>1)
                    dcnt=dcnt+1;
                    if((dcnt>nalpha)&&(dbuild<=casedata{casenoout}.build))
                        dbuild=dbuild+1;
                        dcnt=1;
                    end
                end
            else
                idxaph=find(casedata{casenoout}.alpha==str2double(line(5:14)));
                switch state
                case 'dampreadm1'
                    casedata{casenoout}.cnq(idxaph,idxm,idxa,dbuild)=getcoeffs(line(15:25));
                    casedata{casenoout}.cmq(idxaph,idxm,idxa,dbuild)=getcoeffs(line(26:36));
                    casedata{casenoout}.caq(idxaph,idxm,idxa,dbuild)=getcoeffs(line(37:47));
                    casedata{casenoout}.cnad(idxaph,idxm,idxa,dbuild)=getcoeffs(line(48:58));
                    casedata{casenoout}.cmad(idxaph,idxm,idxa,dbuild)=getcoeffs(line(59:69));
                    if((casedata{casenoout}.build>1)&&(casedata{casenoout}.nolat==true))
                        dcnt=dcnt+1;
                        if((dcnt>nalpha)&&...
                            (dbuild<=(casedata{casenoout}.build-...
                            casedata{casenoout}.config.fin1.avail-...
                            casedata{casenoout}.config.fin2.avail-...
                            casedata{casenoout}.config.fin3.avail-...
                            casedata{casenoout}.config.fin4.avail)))

                            dbuild=dbuild+1;
                            dcnt=1;
                        end
                    end
                case 'dampreadm2'
                    casedata{casenoout}.cyr(idxaph,idxm,idxa,dbuild)=getcoeffs(line(15:25));
                    casedata{casenoout}.cnr(idxaph,idxm,idxa,dbuild)=getcoeffs(line(26:36));
                    casedata{casenoout}.clr(idxaph,idxm,idxa,dbuild)=getcoeffs(line(37:47));
                    casedata{casenoout}.cyp(idxaph,idxm,idxa,dbuild)=getcoeffs(line(48:58));
                    casedata{casenoout}.cnp(idxaph,idxm,idxa,dbuild)=getcoeffs(line(59:69));
                    casedata{casenoout}.clp(idxaph,idxm,idxa,dbuild)=getcoeffs(line(70:80));
                    if(casedata{casenoout}.build>1)
                        dcnt=dcnt+1;
                        if((dcnt>nalpha)&&...
                            (dbuild<=(casedata{casenoout}.build-...
                            casedata{casenoout}.config.fin1.avail-...
                            casedata{casenoout}.config.fin2.avail-...
                            casedata{casenoout}.config.fin3.avail-...
                            casedata{casenoout}.config.fin4.avail)))

                            dbuild=dbuild+1;
                            dcnt=1;
                        end
                    end
                end
            end
        end

        function configinit()
            if(~isfield(casedata{casenoout},'eps')&&...
                casedata{casenoout}.config.downwash&&...
                ~(casedata{casenoout}.hsspn/casedata{casenoout}.wsspn==2.5))

                nalpha=casedata{casenoout}.nalpha;
                [nmach,nalt]=getnmachnalt();
                nbuild=casedata{casenoout}.build;
                ngh=casedata{casenoout}.ngh;
                ndelta=1;

                if(((casedata{casenoout}.highsym==1)||(casedata{casenoout}.highasy==1))...
                    &&(casedata{casenoout}.ngh>0))
                    ndelta=casedata{casenoout}.ndelta;
                end

                casedata{casenoout}.qqinf=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.eps=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
                casedata{casenoout}.depsdalp=99999*ones(nalpha,nmach,nalt,nbuild,ngh+1,ndelta);
            end
        end

        function configread()
            if(casedata{casenoout}.config.downwash&&...
                ~(casedata{casenoout}.hsspn/casedata{casenoout}.wsspn==2.5))

                replacenandm()
                idxdel=sgcnt;
                if((casedata{casenoout}.ngh>0)&&...
                    ((casedata{casenoout}.highsym==1)||(casedata{casenoout}.highasy==1))&&...
                    (idxgh==casedata{casenoout}.ngh)&&...
                    ((casedata{casenoout}.build==1)||(sbuild>casedata{casenoout}.build)))
                    idxdel=sgcnt-1;
                end
                idxaph=find(casedata{casenoout}.alpha==str2double(line(37:41)));
                if sbuild>1

                    ebuild=sbuild-1;
                else
                    ebuild=1;
                end
                casedata{casenoout}.eps(idxaph,idxm,idxa,ebuild,idxgh,idxdel)=getcoeffs(line(57:63));
                casedata{casenoout}.qqinf(idxaph,idxm,idxa,ebuild,idxgh,idxdel)=getcoeffs(line(48:52));
                casedata{casenoout}.depsdalp(idxaph,idxm,idxa,ebuild,idxgh,idxdel)=getcoeffs(line(71:end));

            end
        end

        function triminit()
            nalpha=casedata{casenoout}.nalpha;
            [nmach,nalt]=getnmachnalt();

            casedata{casenoout}.cl_utrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cd_utrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cm_utrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.delt_trim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.dcl_trim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.dclmax_trim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.dcdi_trim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.dcdmin_trim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cha_trim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.chd_trim=99999*ones(nalpha,nmach,nalt);
        end

        function trimhtinit()
            nalpha=casedata{casenoout}.nalpha;
            [nmach,nalt]=getnmachnalt();

            casedata{casenoout}.cl_tailutrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cd_tailutrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cm_tailutrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.hm_tailutrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.aliht_tailtrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cl_tailtrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cd_tailtrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.cm_tailtrim=99999*ones(nalpha,nmach,nalt);
            casedata{casenoout}.hm_tailtrim=99999*ones(nalpha,nmach,nalt);
        end

        function trimhtclcdinit()
            if(~isfield(casedata{casenoout},'cl_trim'))
                nalpha=casedata{casenoout}.nalpha;
                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.cl_trimi=99999*ones(nalpha,nmach,nalt);
                casedata{casenoout}.cd_trimi=99999*ones(nalpha,nmach,nalt);
            end
        end

        function auxbodyinit()
            if~isfield(casedata{casenoout},'wetarea_b')
                [nmach,nalt]=getnmachnalt();
                cnt=1;

                nruns=getnruns();

                casedata{casenoout}.wetarea_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.xcg_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.zcg_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.basearea_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.cd0_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.basedrag_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.fricdrag_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.presdrag_b=99999*ones(nmach,nalt,nruns);
            end
        end

        function auxplanttinit()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'area_w_tt')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_w_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_w_tt=99999*ones(nmach,nalt,nruns);
                end
            case 'auxhtread'
                if~isfield(casedata{casenoout},'area_ht_tt')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_ht_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_ht_tt=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvtread'
                if~isfield(casedata{casenoout},'area_vt_tt')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vt_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vt_tt=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvfread'
                if~isfield(casedata{casenoout},'area_vf_tt')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vf_tt=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vf_tt=99999*ones(nmach,nalt,nruns);
                end
            end
        end

        function auxplanttread()
            switch state_old
            case 'auxwingread'
                idxrun=wcnt;
                casedata{casenoout}.area_w_tt(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_w_tt(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_w_tt(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_w_tt(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_w_tt(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_w_tt(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_w_tt(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_w_tt(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_w_tt(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxhtread'
                idxrun=htcnt;
                casedata{casenoout}.area_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_ht_tt(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvtread'
                idxrun=vtcnt;
                casedata{casenoout}.area_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vt_tt(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvfread'
                idxrun=vfcnt;
                casedata{casenoout}.area_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vf_tt(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            end
        end

        function auxplanteinit()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'area_w_te')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_w_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_w_te=99999*ones(nmach,nalt,nruns);
                end
            case 'auxhtread'
                if~isfield(casedata{casenoout},'area_ht_te')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_ht_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_ht_te=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvtread'
                if~isfield(casedata{casenoout},'area_vt_te')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vt_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vt_te=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvfread'
                if~isfield(casedata{casenoout},'area_vf_te')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vf_te=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vf_te=99999*ones(nmach,nalt,nruns);
                end
            end
        end

        function auxplanteread()
            switch state_old
            case 'auxwingread'
                idxrun=wcnt;
                casedata{casenoout}.area_w_te(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_w_te(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_w_te(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_w_te(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_w_te(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_w_te(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_w_te(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_w_te(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_w_te(idxm,idxa,idxrun)=getcoeffs(line(120:end));
                wcnt=incrementcnt(wcnt);
            case 'auxhtread'
                idxrun=htcnt;
                casedata{casenoout}.area_ht_te(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_ht_te(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_ht_te(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_ht_te(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_ht_te(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_ht_te(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_ht_te(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_ht_te(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_ht_te(idxm,idxa,idxrun)=getcoeffs(line(120:end));
                htcnt=incrementcnt(htcnt);
            case 'auxvtread'
                idxrun=vtcnt;
                casedata{casenoout}.area_vt_te(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vt_te(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vt_te(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vt_te(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vt_te(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vt_te(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vt_te(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vt_te(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vt_te(idxm,idxa,idxrun)=getcoeffs(line(120:end));
                vtcnt=incrementcnt(vtcnt);
            case 'auxvfread'
                idxrun=vfcnt;
                casedata{casenoout}.area_vf_te(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vf_te(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vf_te(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vf_te(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vf_te(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vf_te(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vf_te(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vf_te(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vf_te(idxm,idxa,idxrun)=getcoeffs(line(120:end));
                vfcnt=incrementcnt(vfcnt);
            end
        end

        function cntout=incrementcnt(cntin)

            cntout=cntin+1;
        end

        function auxplantiinit()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'area_w_ti')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_w_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_w_ti=99999*ones(nmach,nalt,nruns);
                end
            case 'auxhtread'
                if~isfield(casedata{casenoout},'area_ht_ti')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_ht_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_ht_ti=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvtread'
                if~isfield(casedata{casenoout},'area_vt_ti')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vt_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vt_ti=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvfread'
                if~isfield(casedata{casenoout},'area_vf_ti')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vf_ti=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vf_ti=99999*ones(nmach,nalt,nruns);
                end
            end
        end

        function auxplantiread()
            switch state_old
            case 'auxwingread'
                idxrun=wcnt;
                casedata{casenoout}.area_w_ti(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_w_ti(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_w_ti(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_w_ti(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_w_ti(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_w_ti(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_w_ti(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_w_ti(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_w_ti(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxhtread'
                idxrun=htcnt;
                casedata{casenoout}.area_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_ht_ti(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvtread'
                idxrun=vtcnt;
                casedata{casenoout}.area_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vt_ti(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvfread'
                idxrun=vfcnt;
                casedata{casenoout}.area_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vf_ti(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            end
        end

        function auxplaneiinit()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'area_w_ei')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_w_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_w_ei=99999*ones(nmach,nalt,nruns);
                end
            case 'auxhtread'
                if~isfield(casedata{casenoout},'area_ht_ei')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_ht_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_ht_ei=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvtread'
                if~isfield(casedata{casenoout},'area_vt_ei')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vt_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vt_ei=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvfread'
                if~isfield(casedata{casenoout},'area_vf_ei')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vf_ei=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vf_ei=99999*ones(nmach,nalt,nruns);
                end
            end

        end

        function auxplaneiread()
            switch state_old
            case 'auxwingread'
                idxrun=wcnt;
                casedata{casenoout}.area_w_ei(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_w_ei(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_w_ei(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_w_ei(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_w_ei(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_w_ei(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_w_ei(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_w_ei(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_w_ei(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxhtread'
                idxrun=htcnt;
                casedata{casenoout}.area_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_ht_ei(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvtread'
                idxrun=vtcnt;
                casedata{casenoout}.area_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vt_ei(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvfread'
                idxrun=vfcnt;
                casedata{casenoout}.area_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vf_ei(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            end
        end

        function auxplanoinit()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'area_w_o')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_w_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_w_o=99999*ones(nmach,nalt,nruns);
                end
            case 'auxhtread'
                if~isfield(casedata{casenoout},'area_ht_o')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_ht_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_ht_o=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvtread'
                if~isfield(casedata{casenoout},'area_vt_o')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vt_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vt_o=99999*ones(nmach,nalt,nruns);
                end
            case 'auxvfread'
                if~isfield(casedata{casenoout},'area_vf_o')
                    [nmach,nalt]=getnmachnalt();
                    nruns=getnruns();

                    casedata{casenoout}.area_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.taperratio_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.aspectratio_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcsweep_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.mac_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.qcmac_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.ymac_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.cd0_vf_o=99999*ones(nmach,nalt,nruns);
                    casedata{casenoout}.friccoeff_vf_o=99999*ones(nmach,nalt,nruns);
                end
            end
        end

        function auxplanoread()
            switch state_old
            case 'auxwingread'
                idxrun=wcnt;
                casedata{casenoout}.area_w_o(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_w_o(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_w_o(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_w_o(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_w_o(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_w_o(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_w_o(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_w_o(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_w_o(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxhtread'
                idxrun=htcnt;
                casedata{casenoout}.area_ht_o(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_ht_o(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_ht_o(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_ht_o(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_ht_o(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_ht_o(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_ht_o(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_ht_o(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_ht_o(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvtread'
                idxrun=vtcnt;
                casedata{casenoout}.area_vt_o(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vt_o(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vt_o(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vt_o(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vt_o(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vt_o(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vt_o(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vt_o(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vt_o(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            case 'auxvfread'
                idxrun=vfcnt;
                casedata{casenoout}.area_vf_o(idxm,idxa,idxrun)=getcoeffs(line(22:32));
                casedata{casenoout}.taperratio_vf_o(idxm,idxa,idxrun)=getcoeffs(line(36:41));
                casedata{casenoout}.aspectratio_vf_o(idxm,idxa,idxrun)=getcoeffs(line(45:55));
                casedata{casenoout}.qcsweep_vf_o(idxm,idxa,idxrun)=getcoeffs(line(59:65));
                casedata{casenoout}.mac_vf_o(idxm,idxa,idxrun)=getcoeffs(line(69:78));
                casedata{casenoout}.qcmac_vf_o(idxm,idxa,idxrun)=getcoeffs(line(82:91));
                casedata{casenoout}.ymac_vf_o(idxm,idxa,idxrun)=getcoeffs(line(95:104));
                casedata{casenoout}.cd0_vf_o(idxm,idxa,idxrun)=getcoeffs(line(108:117));
                casedata{casenoout}.friccoeff_vf_o(idxm,idxa,idxrun)=getcoeffs(line(120:end));
            end
        end

        function auxlemacinitread()
            if~isfield(casedata{casenoout},'lemac')
                [nmach,nalt]=getnmachnalt();
                cnt=1;

                casedata{casenoout}.lemac=99999*ones(nmach,nalt);
            end
            casedata{casenoout}.lemac(idxm,idxa)=getcoeffs(line(87:93));
        end

        function auxclab_winitread()
            if~isfield(casedata{casenoout},'cla_b_w')
                [nmach,nalt]=getnmachnalt();
                wcnt=1;
                nruns=getnruns();

                casedata{casenoout}.cla_b_w=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.cla_w_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.k_b_w=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.k_w_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.xacc_b_w=99999*ones(nmach,nalt,nruns);
            end
            idxrun=wcnt;
            casedata{casenoout}.cla_b_w(idxm,idxa,idxrun)=getcoeffs(line(21:30));
            casedata{casenoout}.cla_w_b(idxm,idxa,idxrun)=getcoeffs(line(45:54));
            casedata{casenoout}.k_b_w(idxm,idxa,idxrun)=getcoeffs(line(67:76));
            casedata{casenoout}.k_w_b(idxm,idxa,idxrun)=getcoeffs(line(89:98));
            casedata{casenoout}.xacc_b_w(idxm,idxa,idxrun)=getcoeffs(line(115:end));
            wcnt=wcnt+1;
        end

        function auxclab_htinitread()
            if~isfield(casedata{casenoout},'cla_b_h')
                [nmach,nalt]=getnmachnalt();
                htcnt=1;
                nruns=getnruns();

                casedata{casenoout}.cla_b_h=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.cla_h_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.k_b_h=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.k_h_b=99999*ones(nmach,nalt,nruns);
                casedata{casenoout}.xacc_b_h=99999*ones(nmach,nalt,nruns);
            end
            idxrun=htcnt;
            casedata{casenoout}.cla_b_h(idxm,idxa,idxrun)=getcoeffs(line(21:30));
            casedata{casenoout}.cla_h_b(idxm,idxa,idxrun)=getcoeffs(line(45:54));
            casedata{casenoout}.k_b_h(idxm,idxa,idxrun)=getcoeffs(line(67:76));
            casedata{casenoout}.k_h_b(idxm,idxa,idxrun)=getcoeffs(line(89:98));
            casedata{casenoout}.xacc_b_h(idxm,idxa,idxrun)=getcoeffs(line(115:end));
            htcnt=htcnt+1;
        end

        function auxsideinitread()
            if~isfield(casedata{casenoout},'sidewash')
                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.sidewash=99999*ones(nmach,nalt);
            end
            casedata{casenoout}.sidewash(idxm,idxa)=getcoeffs(line(78:end));
        end

        function auxivinit()
            if~isfield(casedata{casenoout},'hiv_b_w')
                nalpha=casedata{casenoout}.nalpha;
                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.hiv_b_w=99999*ones(nalpha,nmach,nalt);
                casedata{casenoout}.hiv_w_h=99999*ones(nalpha,nmach,nalt);
                casedata{casenoout}.hiv_b_h=99999*ones(nalpha,nmach,nalt);
                casedata{casenoout}.gamma=99999*ones(nalpha,nmach,nalt);
                casedata{casenoout}.gamma2pialpvr=99999*ones(nalpha,nmach,nalt);
            end
        end

        function auxivread()
            idxaph=find(casedata{casenoout}.alpha==str2double(line(16:22)));
            casedata{casenoout}.iv_b_w(idxaph,idxm,idxa)=getcoeffs(line(29:39));
            casedata{casenoout}.iv_w_h(idxaph,idxm,idxa)=getcoeffs(line(46:56));
            casedata{casenoout}.iv_b_h(idxaph,idxm,idxa)=getcoeffs(line(63:73));
            casedata{casenoout}.gamma(idxaph,idxm,idxa)=getcoeffs(line(80:90));
            casedata{casenoout}.gamma2pialpvr(idxaph,idxm,idxa)=getcoeffs(line(105:end));

        end

        function auxddinc1initread()
            if~isfield(casedata{casenoout},'clpgammacl0')
                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.clpgammacl0=99999*ones(nmach,nalt);
                casedata{casenoout}.clpgammaclp=99999*ones(nmach,nalt);
                casedata{casenoout}.cnptheta=99999*ones(nmach,nalt);
            end
            casedata{casenoout}.clpgammacl0(idxm,idxa)=getcoeffs(line(28:38));
            casedata{casenoout}.clpgammaclp(idxm,idxa)=getcoeffs(line(70:80));
            casedata{casenoout}.cnptheta(idxm,idxa)=getcoeffs(line(98:end));
        end

        function auxddinc2initread()
            if~isfield(casedata{casenoout},'cypgamma')
                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.cypgamma=99999*ones(nmach,nalt);
                casedata{casenoout}.cypcl=99999*ones(nmach,nalt);
            end
            casedata{casenoout}.cypgamma(idxm,idxa)=getcoeffs(line(42:52));
            casedata{casenoout}.cypcl(idxm,idxa)=getcoeffs(line(88:end));
        end

        function auxddincinit()
            if~isfield(casedata{casenoout},'clbgamma')
                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.clbgamma=99999*ones(nmach,nalt);
                casedata{casenoout}.cmothetaw=99999*ones(nmach,nalt);
                casedata{casenoout}.cmothetah=99999*ones(nmach,nalt);
            end
        end

        function auxcanardinit()
            if~isfield(casedata{casenoout},'despdalpeff')
                [nmach,nalt]=getnmachnalt();
                nalpha=casedata{casenoout}.nalpha;

                casedata{casenoout}.espeff=99999*ones(nalpha,nmach,nalt);
                casedata{casenoout}.despdalpeff=99999*ones(nalpha,nmach,nalt);
            end
        end

        function auxcdlinitread()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'clbcl_w')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.cdlcl2_w=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbcl_w=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.cdlcl2_w(idxm,idxa)=getcoeffs(line(51:61));
                casedata{casenoout}.clbcl_w(idxm,idxa)=getcoeffs(line(75:end));
            case 'auxhtread'
                if~isfield(casedata{casenoout},'clbcl_ht')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.cdlcl2_ht=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbcl_ht=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.cdlcl2_ht(idxm,idxa)=getcoeffs(line(51:61));
                casedata{casenoout}.clbcl_ht(idxm,idxa)=getcoeffs(line(75:end));
            end
        end

        function auxfmachinitread()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'fmach_w')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.fmach0_w=99999*ones(nmach,nalt);
                    casedata{casenoout}.fmach_w=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.fmach0_w(idxm,idxa)=getcoeffs(line(51:61));
                casedata{casenoout}.fmach_w(idxm,idxa)=getcoeffs(line(105:end));
            case 'auxhtread'
                if~isfield(casedata{casenoout},'fmach_ht')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.fmach0_ht=99999*ones(nmach,nalt);
                    casedata{casenoout}.fmach_ht=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.fmach0_ht(idxm,idxa)=getcoeffs(line(51:61));
                casedata{casenoout}.fmach_ht(idxm,idxa)=getcoeffs(line(105:end));
            end

        end

        function auxmachainitread()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'macha_w')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.macha_w=99999*ones(nmach,nalt);
                    casedata{casenoout}.machb_w=99999*ones(nmach,nalt);
                    casedata{casenoout}.claa_w=99999*ones(nmach,nalt);
                    casedata{casenoout}.clab_w=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.macha_w(idxm,idxa)=getcoeffs(line(32:37));
                casedata{casenoout}.machb_w(idxm,idxa)=getcoeffs(line(76:81));
                casedata{casenoout}.claa_w(idxm,idxa)=getcoeffs(line(51:61));
                casedata{casenoout}.clab_w(idxm,idxa)=getcoeffs(line(95:end));
            case 'auxhtread'
                if~isfield(casedata{casenoout},'macha_ht')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.macha_ht=99999*ones(nmach,nalt);
                    casedata{casenoout}.machb_ht=99999*ones(nmach,nalt);
                    casedata{casenoout}.claa_ht=99999*ones(nmach,nalt);
                    casedata{casenoout}.clab_ht=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.macha_ht(idxm,idxa)=getcoeffs(line(32:37));
                casedata{casenoout}.machb_ht(idxm,idxa)=getcoeffs(line(76:81));
                casedata{casenoout}.claa_ht(idxm,idxa)=getcoeffs(line(51:61));
                casedata{casenoout}.clab_ht(idxm,idxa)=getcoeffs(line(95:end));
            end
        end

        function auxclbminitread()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'clbm06_w')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.clbm06_w=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbm14_w=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.clbm06_w(idxm,idxa)=getcoeffs(line(64:74));
                casedata{casenoout}.clbm14_w(idxm,idxa)=getcoeffs(line(95:end));
            case 'auxhtread'
                if~isfield(casedata{casenoout},'clbm06_ht')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.clbm06_ht=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbm14_ht=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.clbm06_ht(idxm,idxa)=getcoeffs(line(64:74));
                casedata{casenoout}.clbm14_ht(idxm,idxa)=getcoeffs(line(95:end));
            end
        end

        function auxclalpinit()
            switch state_old
            case 'auxwingread'
                if~isfield(casedata{casenoout},'clalp_w')
                    cnt=1;
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.clalpmach_w=99999*ones(5,nmach,nalt);
                    casedata{casenoout}.clalp_w=99999*ones(5,nmach,nalt);
                end
            case 'auxhtread'
                if~isfield(casedata{casenoout},'clalp_ht')
                    cnt=1;
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.clalpmach_ht=99999*ones(5,nmach,nalt);
                    casedata{casenoout}.clalp_ht=99999*ones(5,nmach,nalt);
                end
            end
        end

        function auxclalpread()
            switch state_old
            case 'auxwingread'

                casedata{casenoout}.clalpmach_w(cnt,idxm,idxa)=getcoeffs(line(54:59));
                casedata{casenoout}.clalp_w(cnt,idxm,idxa)=getcoeffs(line(74:end));
            case 'auxhtread'

                casedata{casenoout}.clalpmach_ht(cnt,idxm,idxa)=getcoeffs(line(54:59));
                casedata{casenoout}.clalp_ht(cnt,idxm,idxa)=getcoeffs(line(74:end));
            end
            cnt=cnt+1;
        end

        function auxclbinitread()
            switch state_old
            case 'auxwbread'
                if~isfield(casedata{casenoout},'clbcl_wb')
                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.clbcl_wb=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbclmfb_wb=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbm14_wb=99999*ones(nmach,nalt);
                    casedata{casenoout}.cnam14_wb=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.clbcl_wb(idxm,idxa)=getcoeffs(line(21:31));
                casedata{casenoout}.clbclmfb_wb(idxm,idxa)=getcoeffs(line(50:60));
                casedata{casenoout}.clbm14_wb(idxm,idxa)=getcoeffs(line(81:91));
                casedata{casenoout}.cnam14_wb(idxm,idxa)=getcoeffs(line(109:end));

            case 'auxbhtread'
                if~isfield(casedata{casenoout},'clbcl_bht')

                    [nmach,nalt]=getnmachnalt();

                    casedata{casenoout}.clbcl_bht=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbclmfb_bht=99999*ones(nmach,nalt);
                    casedata{casenoout}.clbm14_bht=99999*ones(nmach,nalt);
                    casedata{casenoout}.cnam14_bht=99999*ones(nmach,nalt);
                end
                casedata{casenoout}.clbcl_bht(idxm,idxa)=getcoeffs(line(21:31));
                casedata{casenoout}.clbclmfb_bht(idxm,idxa)=getcoeffs(line(50:60));
                casedata{casenoout}.clbm14_bht(idxm,idxa)=getcoeffs(line(81:91));
                casedata{casenoout}.cnam14_bht(idxm,idxa)=getcoeffs(line(109:end));
            end
        end

        function auxdragdinitread()
            if~isfield(casedata{casenoout},'dragdiv')

                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.dragdiv=99999*ones(nmach,nalt);
            end
            casedata{casenoout}.dragdiv(idxm,idxa)=getcoeffs(line(78:end));
        end

        function aux0draginit()
            if~isfield(casedata{casenoout},'cd0')
                cnt=1;
                [nmach,nalt]=getnmachnalt();

                casedata{casenoout}.cd0mach=99999*ones(4,nmach,nalt);
                casedata{casenoout}.cd0=99999*ones(4,nmach,nalt);
            end
        end

        function specinit()
            if~isfield(casedata{casenoout},'time')
                nt=casedata{casenoout}.nalpha;
                [nmach,nalt]=getnmachnalt();


                idxm=1;
                idxa=1;

                casedata{casenoout}.time=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.ctrlfrc=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.locmach=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.reynum=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.locpres=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.dynpres=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.blayer{nmach,nalt,1}=' ';
                casedata{casenoout}.ctrlcoeff=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.corrcoeff=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.sonicamp=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.ampfact=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.vacthr=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.minpres=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.minjet=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.jetpres=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.massflow=99999*ones(nmach,nalt,nt);
                casedata{casenoout}.propelwt=99999*ones(nmach,nalt,nt);
            end

        end

        function specread()
            switch line(3:10)
            case 'TIME (SE'
                casedata{casenoout}.time(idxm,idxa,:)=getcoeffs(line(33:end));
            case 'CONTROL '
                casedata{casenoout}.ctrlfrc(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'LOCAL MA'
                casedata{casenoout}.locmach(idxm,idxa,:)=getcoeffs(line(33:end));
            case 'REYNOLDS'
                casedata{casenoout}.reynum(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'LOCAL PR'
                casedata{casenoout}.locpres(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'DYNAMIC '
                casedata{casenoout}.dynpres(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'BOUNDARY'
                casedata{casenoout}.blayer{idxm,idxa,1}=line(30:end);
            case 'CONTROL-'
                casedata{casenoout}.ctrlcoeff(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'CORRECTE'
                casedata{casenoout}.corrcoeff(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'SONIC AM'
                casedata{casenoout}.sonicamp(idxm,idxa,:)=getcoeffs(line(33:end));
            case 'AMPLIFIC'
                casedata{casenoout}.ampfact(idxm,idxa,:)=getcoeffs(line(33:end));
            case 'VACUUM T'
                casedata{casenoout}.vacthr(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'MIN. PRE'
                casedata{casenoout}.minpres(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'MIN. JET'
                casedata{casenoout}.minjet(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'JET PRES'
                casedata{casenoout}.jetpres(idxm,idxa,:)=getcoeffs(line(30:end));
            case 'MASS-FLO'
                casedata{casenoout}.massflow(idxm,idxa,:)=getcoeffs(line(33:end));
            case 'PROPELLA'
                casedata{casenoout}.propelwt(idxm,idxa,:)=getcoeffs(line(31:end));

                loop=casedata{casenoout}.loop;

                if(loop==2)

                    nmach=casedata{casenoout}.nmach;
                    idxm=idxm+1;
                    if idxm>nmach
                        idxm=1;
                        idxa=idxa+1;
                    end
                elseif(loop==3)

                    nalt=casedata{casenoout}.nalt;
                    idxa=idxa+1;
                    if idxa>nalt
                        idxa=1;
                        idxm=idxm+1;
                    end
                else
                    idxm=idxm+1;
                end
            otherwise
                invaliddataerror();
            end

        end

        function highliftinit()
            nalpha=casedata{casenoout}.nalpha;
            ndelta=casedata{casenoout}.ndelta;
            [nmach,nalt]=getnmachnalt();

            if(casedata{casenoout}.highsym&&...
                ~isfield(casedata{casenoout},'dcl_sym'))
                casedata{casenoout}.dcl_sym=99999*ones(ndelta,nmach,nalt);
                casedata{casenoout}.dcm_sym=99999*ones(ndelta,nmach,nalt);
                casedata{casenoout}.dclmax_sym=99999*ones(ndelta,nmach,nalt);
                casedata{casenoout}.dcdmin_sym=99999*ones(ndelta,nmach,nalt);
                casedata{casenoout}.clad_sym=99999*ones(ndelta,nmach,nalt);
                casedata{casenoout}.cha_sym=99999*ones(ndelta,nmach,nalt);
                casedata{casenoout}.chd_sym=99999*ones(ndelta,nmach,nalt);
                casedata{casenoout}.dcdi_sym=99999*ones(nalpha,ndelta,nmach,nalt);
            end
            if(casedata{casenoout}.highcon&&...
                ~isfield(casedata{casenoout},'fhmcoeff_free'))
                casedata{casenoout}.fc_con=99999*ones(nalpha,ndelta,nmach,nalt);
                casedata{casenoout}.fhmcoeff_free=99999*ones(nalpha,ndelta,nmach,nalt);
                casedata{casenoout}.fhmcoeff_lock=99999*ones(nalpha,ndelta,nmach,nalt);
                casedata{casenoout}.fhmcoeff_gear=99999*ones(nalpha,ndelta,nmach,nalt);
                casedata{casenoout}.ttab_def=99999*ones(nalpha,ndelta,nmach,nalt);
            end
            if(casedata{casenoout}.highasy&&...
                ~isfield(casedata{casenoout},'clroll'))
                cnt=1;
                if(casedata{casenoout}.stype<=2)

                    casedata{casenoout}.xsc=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.hsc=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.dsc=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.clroll=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.cn_asy=99999*ones(ndelta,nmach,nalt);
                elseif(casedata{casenoout}.stype==3)

                    casedata{casenoout}.xsc=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.hsc=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.ddc=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.dsc=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.clroll=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.cn_asy=99999*ones(ndelta,nmach,nalt);
                elseif(casedata{casenoout}.stype==4)

                    casedata{casenoout}.clroll=99999*ones(ndelta,nmach,nalt);
                    casedata{casenoout}.cn_asy=99999*ones(nalpha,ndelta,nmach,nalt);
                else

                    casedata{casenoout}.clroll=99999*ones(nalpha,ndelta,nmach,nalt);
                end
            end
        end

        function hypersinit()
            if~isfield(casedata{casenoout},'df_normal')
                ndelta=casedata{casenoout}.ndelta;
                nalpha=casedata{casenoout}.nalpha;
                nmach=casedata{casenoout}.nmach;

                casedata{casenoout}.df_normal=99999*ones(nalpha,ndelta,nmach);
                casedata{casenoout}.df_axial=99999*ones(nalpha,ndelta,nmach);
                casedata{casenoout}.cm_normal=99999*ones(nalpha,ndelta,nmach);
                casedata{casenoout}.cm_axial=99999*ones(nalpha,ndelta,nmach);
                casedata{casenoout}.cp_normal=99999*ones(nalpha,ndelta,nmach);
                casedata{casenoout}.cp_axial=99999*ones(nalpha,ndelta,nmach);
            end
        end

        function hypcpnread()
            idxaph=find(casedata{casenoout}.alpha==str2double(line(4:8)));
            format={(16:24),(26:34),(36:44),(46:54),(56:64)...
            ,(66:74),(76:84),(86:94),(96:104),(106:114)};
            for k=1:casedata{casenoout}.ndelta
                casedata{casenoout}.cp_normal(idxaph,k,idxm)=getcoeffs(line(format{k}));
            end
        end

        function hypcparead()
            idxaph=find(casedata{casenoout}.alpha==str2double(line(4:8)));
            format={(16:24),(26:34),(36:44),(46:54),(56:64)...
            ,(66:74),(76:84),(86:94),(96:104),(106:114)};
            for k=1:casedata{casenoout}.ndelta
                casedata{casenoout}.cp_axial(idxaph,k,idxm)=getcoeffs(line(format{k}));
            end
        end

        function[nmach,nalt]=getnmachnalt()
            nmach=casedata{casenoout}.nmach;
            nalt=1;

            if(((casedata{casenoout}.loop~=1)||...
                (casedata{casenoout}.nalt>0)))
                nalt=casedata{casenoout}.nalt;
            end
        end

        function nruns=getnruns()
            nruns=1;

            if(casedata{casenoout}.hypers==1)
                nruns=2;
            end
        end

    end

    function output=getcoeffs(line)

        output=str2num(line);%#ok<ST2NM>

        if isempty(output)
            output=99999;
        end
    end

    function replacenandm()

        if usenan
            line=strrep(line,'NA ','NaN');
            line=strrep(line,'NDM','NaN');
        else
            line=strrep(line,'NA','00');
            line=strrep(line,'NDM','000');
        end


        line=strrep(line,'************','000000000000');
        line=strrep(line,'***********','00000000000');
        line=strrep(line,'**********','0000000000');
        line=strrep(line,'*******','0000000');
        line=strrep(line,'******','000000');
        line=strrep(line,'*****','00000');
    end


end

























































