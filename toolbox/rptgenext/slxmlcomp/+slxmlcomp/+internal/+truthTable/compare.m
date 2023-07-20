function compare(block1,block2,type,comparisonParameters)



























    if isempty(block1)
        i_show_one(block2);
    elseif isempty(block2)
        i_show_one(block1);
    else
        i_compare(block1,block2,type,comparisonParameters);
    end


    function i_show_one(block)

        [~,tt]=i_decode(block);
        tt.view;


        function i_compare(block1,block2,type,comparisonParameters)


            [text1,name1]=i_get_text(block1,type);
            [text2,name2]=i_get_text(block2,type);

            s1=com.mathworks.toolbox.rptgenslxmlcomp.plugins.truthtable.TruthTableSource(name1,text1);
            s2=com.mathworks.toolbox.rptgenslxmlcomp.plugins.truthtable.TruthTableSource(name2,text2);
            selection=com.mathworks.comparisons.selection.ComparisonSelection(s1,s2);
            selection.addAll(comparisonParameters);
            com.mathworks.comparisons.main.ComparisonUtilities.startComparisonNoMatlabDispatcher(selection);
            return;


            function[block,tt]=i_decode(location)

                colon=find(location==':');
                assert(~isempty(colon),'Valid Truth Table location must contain a colon');
                colon=colon(end);
                block=location(1:colon-1);
                ssid=location(colon+1:end);
                tt=slxmlcomp.internal.stateflow.chart.get(block,'Stateflow.TruthTable',ssid);
                if isempty(tt)
                    slxmlcomp.internal.error('reverseannotation:InvalidTruthTableLocation',location);
                end



                function[text,block]=i_get_text(location,type)







                    [block,tt]=i_decode(location);
                    if strcmp(type,'ActionTable')
                        data=tt.ActionTable;
                        action=true;
                    elseif strcmp(type,'ConditionTable')
                        data=tt.ConditionTable;
                        action=false;
                    else
                        assert(false,'Unexpected property name');
                    end

                    if action

                        text=data;
                        for i=1:size(data,1)
                            title=slxmlcomp.internal.message('report:TruthTableDescription',i);
                            str=strread(data{i,1},'%s','delimiter',char(10));
                            text{i,1}=[{title};str(:)];
                            title=slxmlcomp.internal.message('report:TruthTableAction',i);
                            str=strread(data{i,2},'%s','delimiter',char(10));
                            text{i,2}=[{'';title};str(:);{'';''}];
                        end
                    else

                        text=cell(size(data,1),3);
                        for i=1:size(data,1)-1
                            title=slxmlcomp.internal.message('report:TruthTableDescription',i);
                            str=strread(data{i,1},'%s','delimiter',char(10));
                            text{i,1}=[{title};str(:)];
                            title=slxmlcomp.internal.message('report:TruthTableCondition',i);
                            str=strread(data{i,2},'%s','delimiter',char(10));
                            text{i,2}=[{'';title};str(:)];
                            title=slxmlcomp.internal.message('report:TruthTableData',i);
                            str=data(i,2:end);
                            text{i,3}=[{'';title};str(:);{'';''}];
                        end

                        text{end,1}={slxmlcomp.internal.message('report:TruthTableActions')};
                        text{end,2}={};
                        str=data(end,3:end);
                        text{end,3}=str(:);
                    end
                    text=text';
                    text=vertcat(text{:});




                    text=i_linewrap(text,40);
                    text=sprintf('%s\n',text{:});



                    function out=i_linewrap(in,L)


                        lenLines=cellfun('length',in);
                        tooLongBool=lenLines>L;
                        tooLongInd=find(tooLongBool);
                        if isempty(tooLongInd)

                            out=in;
                            return
                        end



                        numExtra=sum(ceil(lenLines(tooLongInd)./L))-length(tooLongInd);
                        out=cell(numel(in)+numExtra,1);
                        n=1;
                        for jj=1:numel(in)
                            this=in{jj};

                            if~tooLongBool(jj)||isempty(this)
                                out{n}=this;
                                n=n+1;
                            else

                                while~isempty(this)
                                    len=min(length(this),L);
                                    out{n}=this(1:len);
                                    n=n+1;
                                    this(1:len)=[];
                                end
                            end
                        end


                        assert(isequal([in{:}],[out{:}]),...
                        'Line wrapping did not preserve input data');
