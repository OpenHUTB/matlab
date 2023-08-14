classdef Reader<rf.file.shared.Reader



    properties(SetAccess=protected)
        MainCommentChar='!'
IndependentVariables
    end

    properties(Abstract,SetAccess=protected)
DataSections
    end

    methods
        function obj=Reader(fname)
            obj=obj@rf.file.shared.Reader(fname);
        end
    end

    methods
        function set.IndependentVariables(obj,newIndependentVariables)
            if~isempty(newIndependentVariables)
                validateattributes(newIndependentVariables,{'rf.file.shared.sandp2d.IndependentVariables'},{'scalar'},'','IndependentVariables')
            end
            obj.IndependentVariables=newIndependentVariables;
        end
    end

    methods(Access=protected,Hidden)
        function processnetdata(obj,netdata)
            netdata(strncmpi('REM',netdata,3))=[];
            if length(netdata)<5
                error(message('rf:rffile:shared:sandp2d:reader:processnetdata:AtLeastFiveLines',obj.Filename))
            end


            var_line_idx=find(strncmpi('VAR',netdata,3)==1);
            num_var_line_idx=numel(var_line_idx);
            if~isempty(var_line_idx)

                temp_idx=find(diff(var_line_idx)>1)+1;

                var_sec_start_lines=var_line_idx([1;temp_idx]);
            else
                var_sec_start_lines=1;
            end

            num_var_sec=numel(var_sec_start_lines);
            indvarnames=cell(num_var_line_idx/num_var_sec,num_var_sec);

            indvarvalues=cell(num_var_line_idx/num_var_sec,num_var_sec);
            obj.DataSections=obj.createemptydatasectionobj;


            for section_num=1:num_var_sec
                if~isequal(section_num,num_var_sec)
                    section_netdata=netdata(var_sec_start_lines(section_num):var_sec_start_lines(section_num+1)-1);
                else
                    section_netdata=netdata(var_sec_start_lines(section_num):end);
                end


                var_line_idx=strncmpi('VAR',section_netdata,3)==1;


                [~,var_lines]=strtok(section_netdata(var_line_idx));


                [tempindvars(:,1),temp]=strtok(var_lines,'=');
                indvarnames(:,section_num)=strtrim(tempindvars(:,1));
                indvarvalues(:,section_num)=num2cell(cellfun(@str2double,strtrim(strtok(strtrim(temp),'='))));


                obj.DataSections(section_num)=processdatasection(obj,section_netdata);
            end

            if~isempty(indvarnames)||~isempty(indvarvalues)
                obj.IndependentVariables=rf.file.shared.sandp2d.IndependentVariables(indvarnames,indvarvalues);
            else
                obj.IndependentVariables=rf.file.shared.sandp2d.IndependentVariables.empty;
            end
        end
    end



    methods(Access=protected,Hidden)
        function[funit,theformat,paramtype,refimpedance,freqconv]=createsmallsignaloptionlist(obj,optline)
            optline=lower(optline);
            cropcell=textscan(optline,'%s');
            cropcell=cropcell{1};
            if~isequal(length(cropcell),8)
                error(message('rf:rffile:shared:sandp2d:reader:createsmallsignaloptionlist:InvalidAcdataOptLine',obj.Filename,optline))
            end

            validfreq_keywords='hz';
            funit=getfrequnit(obj,optline,cropcell,validfreq_keywords,1);


            validformats_keywords={'ma','db','ri','vdb'};
            theformat=getparamformat(obj,optline,cropcell,validformats_keywords,3);


            validparamtypes_keywords={'s','y','z','g','h'};
            paramtype=getparamtype(obj,optline,cropcell,validparamtypes_keywords,2);


            validrefimp_keywords='r';
            refimpedance=getrefimpedance(obj,optline,cropcell,validrefimp_keywords,4);


            validfreqconv_keywords='fc';
            freqconv=getfreqconv(obj,optline,cropcell,validfreqconv_keywords,6);
        end

        function[funit,theformat,refimpedance]=createnoisedataoptionlist(obj,optline)
            optline=lower(optline);
            cropcell=textscan(optline,'%s');
            cropcell=cropcell{1};
            if~isequal(length(cropcell),5)
                error(message('rf:rffile:shared:sandp2d:reader:createnoisedataoptionlist:InvalidNdataOptLine',obj.Filename,optline))
            end

            validfreq_keywords='hz';
            funit=getfrequnit(obj,optline,cropcell,validfreq_keywords,1);


            validformats_keywords={'ma','db','ri'};
            theformat=getparamformat(obj,optline,cropcell,validformats_keywords,3);


            validparamtypes_keywords={'s'};
            getparamtype(obj,optline,cropcell,validparamtypes_keywords,2);


            validrefimp_keywords='r';
            refimpedance=getrefimpedance(obj,optline,cropcell,validrefimp_keywords,4);
        end

        function[formatline,format_line_index]=getformatline(obj,netdata,block_type,nformatlines,nthformatline)


            narginchk(4,5)
            if nargin<5
                nthformatline=nformatlines;
            end
            format_line_index=find(strncmp('%',netdata,1));
            if isempty(format_line_index)
                error(message('rf:rffile:shared:sandp2d:reader:getformatline:MissingFormatLine',obj.Filename,block_type))
            elseif~isequal(nformatlines,Inf)
                if~isequal(numel(format_line_index),nformatlines)
                    error(message('rf:rffile:shared:sandp2d:reader:getformatline:NFormatLines',obj.Filename,nformatlines,block_type))
                end
            end
            formatline=trimtrailingcomments(obj,netdata{format_line_index(nthformatline)});
        end

        function datablock=getdatablock(obj,netdata,blkstartline,...
            blkendline,preallocationblk,...
            numcols,blktype,extra_msg,isonelineblk)
            nidx=blkstartline;
            IDX=1;
            datablock=preallocationblk;
            while nidx<=blkendline
                [dblN,lenN,nidx]=rf.file.shared.parsedataline(obj,netdata{nidx},nidx);
                if~isempty(dblN)
                    if isonelineblk
                        if IDX>1
                            error(message('rf:rffile:shared:sandp2d:reader:getdatablock:OneLineBlk',obj.Filename,blktype,extra_msg))
                        end
                    end
                    if~isequal(lenN,numcols)
                        error(message('rf:rffile:shared:sandp2d:reader:getdatablock:NColBlk',obj.Filename,numcols,blktype,extra_msg))
                    end
                    try
                        datablock(IDX,:)=dblN;
                    catch err
                        if(strcmp(err.identifier,'MATLAB:subsassigndimmismatch'))
                            error(message('rf:rffile:shared:sandp2d:reader:getdatablock:InvalidDataLine',obj.Filename,netdata{nidx-1}))
                        else
                            rethrow(err);
                        end
                    end
                    IDX=IDX+1;
                end
            end
            datablock=datablock(1:IDX-1,:);
        end

        function noiseobj=createnoiseobj(obj,subsection_netdata,subsection_endline_idx)

            option_line_idx=find(strncmp('#',subsection_netdata,1)==1);
            if isempty(option_line_idx)
                error(message('rf:rffile:shared:sandp2d:reader:createnoiseobj:MissingOptLine',obj.Filename))
            elseif~isequal(numel(option_line_idx),1)
                error(message('rf:rffile:shared:sandp2d:reader:createnoiseobj:MoreThanOneOptLine',obj.Filename))
            end
            option_line=trimtrailingcomments(obj,subsection_netdata{option_line_idx});
            option_line=obj.debracket(option_line);
            [nsfunit,nstheformat,nsrefimpedance]=createnoisedataoptionlist(obj,option_line);


            [nsformatline,format_line_idx]=getformatline(obj,subsection_netdata,'NDATA',1);


            nsdata=getdatablock(obj,subsection_netdata,format_line_idx+1,...
            subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),5),...
            5,'NDATA','data section',false);

            noiseobj=rf.file.shared.sandp2d.NoiseData(nsdata,nsfunit,nstheformat,nsrefimpedance,true,nsformatline);
        end

        function imtobj=createimtobj(obj,subsection_netdata,subsection_endline_idx)

            pwr_lvls_line_idx=find(strncmp('#',subsection_netdata,1)==1);
            if isempty(pwr_lvls_line_idx)
                error(message('rf:rffile:shared:sandp2d:reader:createimtobj:MissingPowLvlLine',obj.Filename))
            elseif~isequal(numel(pwr_lvls_line_idx),1)
                error(message('rf:rffile:shared:sandp2d:reader:createimtobj:MoreThanOnePowLvlLine',obj.Filename))
            end
            pwr_lvls_line=trimtrailingcomments(obj,subsection_netdata{pwr_lvls_line_idx});
            imtsiglo=sscanf(pwr_lvls_line(2:end),'%f');
            if~isequal(numel(imtsiglo),2)
                error(message('rf:rffile:shared:sandp2d:reader:createimtobj:MissingPowLvlValues',obj.Filename))
            end
            imtsiglo=imtsiglo.';


            [~,format_line_idx]=getformatline(obj,subsection_netdata,'IMTDATA',1);


            nidx=format_line_idx+1;
            dblN=[];

            while isempty(dblN)
                [dblN,lenN,nidx]=rf.file.shared.parsedataline(obj,subsection_netdata{nidx},nidx);
            end
            nidx=nidx-1;
            IDX=1;
            maxorder=lenN-1;
            imtdata=99*ones(maxorder+1,maxorder+1);
            while nidx<=subsection_endline_idx
                [dblN,lenN,nidx]=rf.file.shared.parsedataline(obj,subsection_netdata{nidx},nidx);
                if~isempty(dblN)
                    imtdata(IDX,1:lenN)=dblN;
                    if~isequal(lenN,maxorder+2-IDX)&&~isequal(lenN,maxorder+1)
                        error(message('rf:rffile:shared:sandp2d:reader:createimtobj:InvalidDataLine',...
                        obj.Filename,subsection_netdata{nidx-1}))
                    end
                    IDX=IDX+1;
                end
            end
            imtdata=imtdata(1:IDX-1,:);

            imtobj=rf.file.shared.sandp2d.IMTData(imtdata,imtsiglo);
        end

        function funit=getfrequnit(obj,optline,cropcell,validoptions,validposition)
            idx=strfind(cropcell{validposition},validoptions);
            if isempty(idx)||~isequal(numel(idx),1)

                error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
            elseif idx==1

                funit='hz';
            else
                prevchar=optline(idx-1);
                switch prevchar
                case{'g','m','k'}
                    funit=lower(horzcat(prevchar,'hz'));
                case ' '
                    funit='hz';
                otherwise

                    error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
                end
            end
        end

        function theformat=getparamformat(obj,optline,cropcell,validoptions,validposition)
            for nn=1:length(validoptions)
                idx=strcmp(cropcell{validposition},validoptions{nn});
                numhits=sum(idx);
                if numhits
                    if numhits>1

                        error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
                    end
                    thisformat=validoptions{nn};
                    break
                end
            end
            if~numhits

                error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
            end
            theformat=lower(thisformat);
        end

        function paramtype=getparamtype(obj,optline,cropcell,validoptions,validposition)


            for nn=1:length(validoptions)
                idx=strcmp(cropcell{validposition},validoptions{nn});
                numhits=sum(idx);
                if numhits
                    if numhits>1

                        error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
                    end
                    thisparam=validoptions{nn};
                    break
                end
            end
            if~numhits

                error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
            end
            paramtype=lower(thisparam);
        end

        function refimpedance=getrefimpedance(obj,optline,cropcell,validoptions,validposition)
            idx=find(strcmp(cropcell{validposition},validoptions));
            if isempty(idx)||~isequal(numel(idx),1)

                error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
            else
                refimpedance=str2double(cropcell{validposition+1});
            end
        end

        function freqconv=getfreqconv(obj,optline,cropcell,validoptions,validposition)
            idx=find(strcmp(cropcell{validposition},validoptions));
            if isempty(idx)||~isequal(numel(idx),1)

                error(message('rf:rffile:shared:sandp2d:reader:getoption:InvalidOptLine',obj.Filename,optline))
            else
                freqconv=([str2double(cropcell{validposition+1}),str2double(cropcell{validposition+2})]);
            end
        end

        function[begin_line_idx,end_line_idx]=findbeginendindices(obj,section_netdata)

            begin_line_idx=find(strncmpi('BEGIN',section_netdata,5)==1);
            end_line_idx=find(strncmpi('END',section_netdata,3)==1);


            if(~isequal(numel(begin_line_idx),numel(end_line_idx))||any(begin_line_idx>end_line_idx))
                error(message('rf:rffile:shared:sandp2d:reader:findbeginendindices:MismatchBeginEnd',obj.Filename))
            end
        end
    end

    methods(Static,Access=protected,Hidden)
        function option_line=debracket(option_line)
            [~,rem]=strtok(option_line,'(');
            rem=deblank(rem);

            if(~isempty(rem)&&strcmp(rem(1),'(')&&strcmp(rem(end),')'))
                option_line=rem(2:end-1);
            end
            option_line=strtrim(option_line);
        end
    end

    methods
        function linestr=trimtrailingcomments(obj,linestr)

            idx1=strfind(linestr,obj.MainCommentChar);
            idx2=strfind(upper(linestr),'REM');

            if~isempty(idx1)&&~isempty(idx2)
                linestr=strtrim(linestr(1:(min(idx1(1),idx2(1))-1)));
            elseif~isempty(idx1)&&isempty(idx2)
                linestr=strtrim(linestr(1:(idx1(1)-1)));
            elseif isempty(idx1)&&~isempty(idx2)
                linestr=strtrim(linestr(1:(idx2(1)-1)));
            end
        end

        function[temp1,temp2,temp3]=reacttostrindataline(obj,linestr,~)%#ok



            error(message('rf:rffile:shared:sandp2d:reader:reacttostrindataline:InvalidDataLine',obj.Filename,linestr))
        end
    end

    methods(Abstract,Static,Access=protected,Hidden)
        block_type=findblocktype(blockstr,lcounter);
        emptyobj=createemptydatasectionobj;
    end

    methods(Abstract,Access=protected,Hidden)
        ds=processdatasection(obj,section_netdata,begin_line_idx,end_line_idx);
    end

    methods
        function out=convertto3ddata(obj,varargin)
            sectionidx=getindex(obj,varargin{:});
            out=obj.DataSections(sectionidx).convertto3ddata;
        end

        function out=smallsignalfreqsinhz(obj,varargin)
            sectionidx=getindex(obj,varargin{:});
            out=obj.DataSections(sectionidx).smallsignalfreqsinhz;
        end

        function out=hasnoise(obj)
            out=false;
            for sectionidx=1:numel(obj.DataSections)
                out=out||obj.DataSections(sectionidx).hasnoise;
            end
        end

        function out=hasimt(obj)
            out=false;
            for sectionidx=1:numel(obj.DataSections)
                out=out||obj.DataSections(sectionidx).hasimt;
            end
        end

        function out=hasindependentvariables(obj)
            out=~isempty(obj.IndependentVariables);
        end

        function out=getindex(obj,varargin)
            out=obj.IndependentVariables.getindex(varargin{:});
        end
    end
end