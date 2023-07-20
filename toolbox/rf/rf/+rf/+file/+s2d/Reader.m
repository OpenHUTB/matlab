classdef Reader<rf.file.shared.sandp2d.Reader



    properties(SetAccess=protected)
DataSections
    end

    methods
        function obj=Reader(fname)
            obj=obj@rf.file.shared.sandp2d.Reader(fname);
        end
    end

    methods
        function set.DataSections(obj,newDatasec)
            if~isempty(newDatasec)
                validateattributes(newDatasec,{'rf.file.s2d.DataSection'},{'vector'},'','DataSections')
            end
            obj.DataSections=newDatasec;
        end
    end

    methods(Access=private,Hidden)
        function[funit,theformat,refimpedance]=creategcomp7optionlist(obj,optline)
            optline=lower(optline);
            cropcell=textscan(optline,'%s');
            cropcell=cropcell{1};
            if~isequal(length(cropcell),6)
                error(message('rf:rffile:s2d:reader:creategcomp7optionlist:InvalidOptLine',obj.Filename,optline))
            end

            validfreq_keywords='hz';
            funit=getfrequnit(obj,optline,cropcell,validfreq_keywords,1);


            validformats_keywords={'dbm'};
            getparamformat(obj,optline,cropcell,validformats_keywords,3);


            validformats_keywords={'ma','db','ri'};
            theformat=getparamformat(obj,optline,cropcell,validformats_keywords,4);


            validparamtypes_keywords={'s'};
            getparamtype(obj,optline,cropcell,validparamtypes_keywords,2);


            validrefimp_keywords='r';
            refimpedance=getrefimpedance(obj,optline,cropcell,validrefimp_keywords,5);
        end
    end

    methods(Access=protected,Hidden)
        function ds=processdatasection(obj,section_netdata)
            [begin_line_idx,end_line_idx]=findbeginendindices(obj,section_netdata);

            total_acdata_sec=0;
            NoiseObj=rf.file.shared.sandp2d.NoiseData.empty;
            IMTObj=rf.file.shared.sandp2d.IMTData.empty;
            total_gcomp1to6_sec=0;
            total_gcomp7_sec=0;
            GCompObj=rf.file.s2d.Gcomp7.empty;
            tempgcomp7=rf.file.s2d.Gcomp7.empty;


            for begin_block_num=1:numel(begin_line_idx)
                subsection_netdata=section_netdata(begin_line_idx(begin_block_num):end_line_idx(begin_block_num)-1);


                subsection_netdata{1}=trimtrailingcomments(obj,subsection_netdata{1});
                block_type=obj.findblocktype(lower(subsection_netdata{1}),1);

                subsection_endline_idx=length(subsection_netdata);
                switch block_type
                case('acdata')
                    total_acdata_sec=total_acdata_sec+1;
                    if~isequal(total_acdata_sec,1)
                        error(message('rf:rffile:s2d:reader:processdatasection:OnlyOneBlkType',obj.Filename,upper(block_type)))
                    end

                    option_line_idx=find(strncmp('#',subsection_netdata,1)==1);
                    if isempty(option_line_idx)
                        error(message('rf:rffile:s2d:reader:processdatasection:MissingOptLine',obj.Filename,upper(block_type)))
                    elseif~isequal(numel(option_line_idx),1)
                        error(message('rf:rffile:s2d:reader:processdatasection:MoreThanOneOptLine',obj.Filename,upper(block_type)))
                    end
                    option_line=trimtrailingcomments(obj,subsection_netdata{option_line_idx});
                    option_line=obj.debracket(option_line);
                    [funit,theformat,paramtype,refimpedance,freqconv]=createsmallsignaloptionlist(obj,option_line);


                    [ssformatline,format_line_idx]=getformatline(obj,subsection_netdata,'ACDATA',1);


                    ssdata=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),9),...
                    9,'ACDATA','data section',false);

                    SmallSignalObj=rf.file.shared.sandp2d.SmallSignalData(ssdata,funit,theformat,refimpedance,paramtype,freqconv,ssformatline);

                case('ndata')

                    if~isempty(NoiseObj)
                        error(message('rf:rffile:s2d:reader:processdatasection:MoreThanOneBlkType',obj.Filename,upper(block_type)))
                    end
                    NoiseObj=createnoiseobj(obj,subsection_netdata,subsection_endline_idx);

                case('imtdata')

                    if~isempty(IMTObj)
                        error(message('rf:rffile:s2d:reader:processdatasection:MoreThanOneBlkType',obj.Filename,upper(block_type)))
                    end
                    IMTObj=createimtobj(obj,subsection_netdata,subsection_endline_idx);

                case('gcomp1')
                    total_gcomp1to6_sec=total_gcomp1to6_sec+1;


                    [gcomp1formatline,format_line_idx]=getformatline(obj,subsection_netdata,'GCOMP1',1);


                    gcomp1data=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),1),...
                    1,'GCOMP1','data section',true);

                    GCompObj=rf.file.s2d.Gcomp1(gcomp1data,gcomp1formatline);

                case('gcomp2')
                    total_gcomp1to6_sec=total_gcomp1to6_sec+1;


                    [gcomp2formatline,format_line_idx]=getformatline(obj,subsection_netdata,'GCOMP2',1);


                    gcomp2data=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),1),...
                    1,'GCOMP2','data section',true);

                    GCompObj=rf.file.s2d.Gcomp2(gcomp2data,gcomp2formatline);

                case('gcomp3')
                    total_gcomp1to6_sec=total_gcomp1to6_sec+1;


                    [gcomp3formatline,format_line_idx]=getformatline(obj,subsection_netdata,'GCOMP3',1);


                    gcomp3data=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),2),...
                    2,'GCOMP3','data section',true);

                    GCompObj=rf.file.s2d.Gcomp3(gcomp3data,gcomp3formatline);

                case('gcomp4')
                    total_gcomp1to6_sec=total_gcomp1to6_sec+1;


                    [gcomp4formatline,format_line_idx]=getformatline(obj,subsection_netdata,'GCOMP4',1);


                    gcomp4data=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),3),...
                    3,'GCOMP4','data section',true);

                    GCompObj=rf.file.s2d.Gcomp4(gcomp4data,gcomp4formatline);

                case('gcomp5')
                    total_gcomp1to6_sec=total_gcomp1to6_sec+1;


                    [gcomp5formatline,format_line_idx]=getformatline(obj,subsection_netdata,'GCOMP5',1);


                    gcomp5data=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),3),...
                    3,'GCOMP5','data section',true);
                    GCompObj=rf.file.s2d.Gcomp5(gcomp5data,gcomp5formatline);

                case('gcomp6')
                    total_gcomp1to6_sec=total_gcomp1to6_sec+1;


                    [gcomp6formatline,format_line_idx]=getformatline(obj,subsection_netdata,'GCOMP6',1);


                    gcomp6data=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),4),...
                    4,'GCOMP6','data section',true);
                    GCompObj=rf.file.s2d.Gcomp6(gcomp6data,gcomp6formatline);

                case('gcomp7')
                    total_gcomp7_sec=total_gcomp7_sec+1;

                    option_line_idx=find(strncmp('#',subsection_netdata,1)==1);
                    if isempty(option_line_idx)
                        error(message('rf:rffile:s2d:reader:processdatasection:MissingOptLine',obj.Filename,upper(block_type)))
                    elseif~isequal(numel(option_line_idx),1)
                        error(message('rf:rffile:s2d:reader:processdatasection:MoreThanOneOptLine',obj.Filename,upper(block_type)))
                    end

                    option_line=trimtrailingcomments(obj,subsection_netdata{option_line_idx});
                    option_line=obj.debracket(option_line);
                    [gcomp7funit,gcomp7theformat,gcomp7refimpedance]=creategcomp7optionlist(obj,option_line);


                    [gcomp7formatline,format_line_idx]=getformatline(obj,subsection_netdata,'GCOMP7',2);


                    gcomp7freq=getdatablock(obj,subsection_netdata,format_line_idx(1)+1,...
                    format_line_idx(2)-1,zeros(1),...
                    1,'GCOMP7','frequency section',true);


                    gcomp7data=getdatablock(obj,subsection_netdata,format_line_idx(2)+1,...
                    subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx(2)),3),...
                    3,'GCOMP7','data section',false);
                    tempgcomp7(total_gcomp7_sec)=rf.file.s2d.Gcomp7(gcomp7data,gcomp7formatline,...
                    gcomp7freq,gcomp7funit,gcomp7theformat,gcomp7refimpedance);
                end


                if~isempty(GCompObj)||~isempty(tempgcomp7)
                    if total_gcomp1to6_sec>1

                        error(message('rf:rffile:s2d:reader:processdatasection:SingleSecGcomp1to6',obj.Filename))
                    elseif obj.hasgcomp&&~isa(GCompObj,class(obj.DataSections(1).GCOMPx))

                        error(message('rf:rffile:s2d:reader:processdatasection:MultiSecGcompx',obj.Filename))
                    end
                end
            end


            if~isempty(tempgcomp7)&&~isa(GCompObj,'rf.file.s2d.Gcomp7')

                error(message('rf:rffile:s2d:reader:processdatasection:SingleSecGcompx',obj.Filename))
            elseif~isempty(tempgcomp7)
                GCompObj=tempgcomp7;
            end

            ds=rf.file.s2d.DataSection(SmallSignalObj,NoiseObj,IMTObj,GCompObj);
        end
    end

    methods(Static,Access=protected,Hidden)
        function block_type=findblocktype(a_string,lcounter)
            if~isempty(strfind(a_string,'acdata'))
                block_type='acdata';
            elseif~isempty(strfind(a_string,'ndata'))
                block_type='ndata';
            elseif~isempty(strfind(a_string,'gcomp1'))
                block_type='gcomp1';
            elseif~isempty(strfind(a_string,'gcomp2'))
                block_type='gcomp2';
            elseif~isempty(strfind(a_string,'gcomp3'))
                block_type='gcomp3';
            elseif~isempty(strfind(a_string,'gcomp4'))
                block_type='gcomp4';
            elseif~isempty(strfind(a_string,'gcomp5'))
                block_type='gcomp5';
            elseif~isempty(strfind(a_string,'gcomp6'))
                block_type='gcomp6';
            elseif~isempty(strfind(a_string,'gcomp7'))
                block_type='gcomp7';
            elseif~isempty(strfind(a_string,'imtdata'))
                block_type='imtdata';
            else
                error(message('rf:rffile:s2d:reader:findblocktype:BlkNotFound',lcounter))
            end
        end

        function emptyobj=createemptydatasectionobj
            emptyobj=rf.file.s2d.DataSection.empty;
        end
    end

    methods
        function out=hasgcomp(obj)
            out=false;
            for sectionidx=1:numel(obj.DataSections)
                out=out||obj.DataSections(sectionidx).hasgcomp;
            end
        end
    end
end
