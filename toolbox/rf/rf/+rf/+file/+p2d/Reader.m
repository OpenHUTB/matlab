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
                validateattributes(newDatasec,{'rf.file.p2d.DataSection'},{'vector'},'','DataSections')
            end
            obj.DataSections=newDatasec;
        end
    end

    methods(Access=protected,Hidden)
        function ds=processdatasection(obj,section_netdata)
            [begin_line_idx,end_line_idx]=findbeginendindices(obj,section_netdata);

            total_acdata_sec=0;
            NoiseObj=rf.file.shared.sandp2d.NoiseData.empty;
            IMTObj=rf.file.shared.sandp2d.IMTData.empty;
            PowerObj=rf.file.p2d.PowerData.empty;


            for begin_block_num=1:numel(begin_line_idx)
                subsection_netdata=section_netdata(begin_line_idx(begin_block_num):end_line_idx(begin_block_num)-1);


                subsection_netdata{1}=trimtrailingcomments(obj,subsection_netdata{1});
                block_type=obj.findblocktype(lower(subsection_netdata{1}),1);

                subsection_endline_idx=length(subsection_netdata);
                switch block_type
                case('acdata')
                    total_acdata_sec=total_acdata_sec+1;
                    if~isequal(total_acdata_sec,1)
                        error(message('rf:rffile:p2d:reader:processdatasection:OnlyOneBlkType',obj.Filename,upper(block_type)))
                    end

                    option_line_idx=find(strncmp('#',subsection_netdata,1)==1);
                    if isempty(option_line_idx)
                        error(message('rf:rffile:p2d:reader:processdatasection:MissingOptLine',obj.Filename,upper(block_type)))
                    elseif~isequal(numel(option_line_idx),1)
                        error(message('rf:rffile:p2d:reader:processdatasection:MoreThanOneOptLine',obj.Filename,upper(block_type)))
                    end
                    option_line=trimtrailingcomments(obj,subsection_netdata{option_line_idx});
                    option_line=obj.debracket(option_line);
                    [funit,theformat,paramtype,refimpedance,freqconv]=createsmallsignaloptionlist(obj,option_line);


                    [ssformatline,format_line_idx]=getformatline(obj,subsection_netdata,'ACDATA',Inf,1);

                    num_fm_line=numel(format_line_idx);
                    if~isequal(mod(num_fm_line,2),1)
                        error(message('rf:rffile:p2d:reader:processdatasection:OddFormatLineExpected',obj.Filename,upper(block_type)))
                    end

                    if isequal(num_fm_line,1)

                        ssdata=getdatablock(obj,subsection_netdata,format_line_idx+1,...
                        subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx),9),...
                        9,'small signal ACDATA','data section',false);
                    else


                        ssdata=getdatablock(obj,subsection_netdata,format_line_idx(1)+1,...
                        format_line_idx(2)-1,zeros((format_line_idx(2)-format_line_idx(1)),9),...
                        9,'small signal ACDATA','data section',false);


                        for ii=2:2:num_fm_line
                            jj=ii/2;
                            powerfrequency=getdatablock(obj,subsection_netdata,format_line_idx(ii)+1,...
                            format_line_idx(ii+1)-1,zeros(1),...
                            1,'large signal ACDATA','data section',true);

                            kk=ii+1;
                            formatlinecell=getformatline(obj,subsection_netdata,'ACDATA',Inf,kk);
                            if~isequal(kk,num_fm_line)
                                powerdata=getdatablock(obj,subsection_netdata,format_line_idx(kk)+1,...
                                format_line_idx(kk+1)-1,zeros((format_line_idx(kk+1)-format_line_idx(kk)),10),...
                                10,'large signal ACDATA','data section',false);
                            else
                                powerdata=getdatablock(obj,subsection_netdata,format_line_idx(kk)+1,...
                                subsection_endline_idx,zeros((subsection_endline_idx-format_line_idx(kk)),10),...
                                10,'large signal ACDATA','data section',false);
                            end
                            PowerObj(jj)=rf.file.p2d.PowerData(powerfrequency,powerdata,formatlinecell);
                        end
                    end

                    SmallSignalObj=rf.file.shared.sandp2d.SmallSignalData(ssdata,funit,theformat,refimpedance,paramtype,freqconv,ssformatline);

                case('ndata')

                    if~isempty(NoiseObj)
                        error(message('rf:rffile:p2d:reader:processdatasection:MoreThanOneBlkType',obj.Filename,upper(block_type)))
                    end
                    NoiseObj=createnoiseobj(obj,subsection_netdata,subsection_endline_idx);

                case('imtdata')

                    if~isempty(IMTObj)
                        error(message('rf:rffile:p2d:reader:processdatasection:MoreThanOneBlkType',obj.Filename,upper(block_type)))
                    end
                    IMTObj=createimtobj(obj,subsection_netdata,subsection_endline_idx);
                end
            end

            ds=rf.file.p2d.DataSection(SmallSignalObj,NoiseObj,IMTObj,PowerObj);
        end
    end

    methods(Static,Access=protected,Hidden)
        function block_type=findblocktype(a_string,lcounter)
            if~isempty(strfind(a_string,'acdata'))
                block_type='acdata';
            elseif~isempty(strfind(a_string,'ndata'))
                block_type='ndata';
            elseif~isempty(strfind(a_string,'imtdata'))
                block_type='imtdata';
            else
                error(message('rf:rffile:p2d:reader:findblocktype:BlkNotFound',lcounter))
            end
        end

        function emptyobj=createemptydatasectionobj
            emptyobj=rf.file.p2d.DataSection.empty;
        end
    end


    methods
        function out=haspowerdata(obj)
            out=false;
            for sectionidx=1:numel(obj.DataSections)
                out=out||obj.DataSections(sectionidx).haspowerdata;
            end
        end
    end
end
