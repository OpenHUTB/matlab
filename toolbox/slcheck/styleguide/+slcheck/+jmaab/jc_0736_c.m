classdef jc_0736_c<slcheck.subcheck
    methods
        function obj=jc_0736_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0736_c';
        end


        function result=run(this)
            result=false;





            spaceLimit=this.getInputParamByName(...
            DAStudio.message(...
            'ModelAdvisor:jmaab:jc_0736_InputMessage'));

            spaceLimit=str2double(spaceLimit);

            if isempty(spaceLimit)||isnan(spaceLimit)
                return;
            end

            spaceLimit=round(spaceLimit);


            sfObj=this.getEntity();

            if isempty(sfObj)
                return;
            end

            if~isa(sfObj,'Stateflow.Transition')
                return;
            end

            labelStringEdit=sfObj.LabelString;
            labelString=sfObj.LabelString;

            offset=0;

            if isempty(labelString)
                return;
            end

            [asts,~]=Advisor.Utils.Stateflow...
            .getAbstractSyntaxTree(sfObj);




            sections=asts.transitionActionSection;


            if isempty(sections)
                return
            end

            for secCount=1:numel(sections)

                section=sections{secCount};

                roots=section.roots;

                if isempty(roots)
                    continue;
                end





                root=roots{1};

                if isempty(root.sourceSnippet)
                    continue;
                end


                startIndex=root.treeStart;






                label_split=regexp(labelString,'\n','split');
                expressionComment='^%.*|/\*.*?\*/|(\/\/)+.*';
                comment_filtered=cellfun(@(x)regexprep(x,expressionComment,'${blanks(numel($0))}'),label_split,'UniformOutput',false);
                comment_filtered=comment_filtered(cellfun(@(x)~isempty(x),comment_filtered));
                labelStr=strjoin(comment_filtered,'\n');

                for iCount=startIndex:-1:1
                    if strcmp(labelStr(iCount),'/')
                        break;
                    end

                end



                trueIndex=iCount+1;


                startIndex=max(trueIndex,1);
                stopIndex=min(startIndex+spaceLimit,...
                length(labelString));


                indent=labelString(startIndex:stopIndex);

                if isempty(indent)
                    continue;
                end



                spaceIndex=regexp(indent,'[ \b\f]');
                tabIndex=regexp(indent,'\t');




                noSpace=~strcmp(indent(1),' ');
                whiteSpace=numel(spaceIndex);


                tabSpace=numel(tabIndex);


                noByteSpace=whiteSpace+4*tabSpace;




                if(noByteSpace==spaceLimit)&&~noSpace
                    continue;
                end

                LSLength=length(labelString);


                labelStringEdit=Advisor.Utils.Naming.formatFlaggedName(...
                labelString,false,...
                [iCount+offset,...
                iCount+offset+spaceLimit],'');

                offset=offset+length(labelStringEdit)-LSLength;


            end

            if 0==offset&&~noSpace
                return;
            end

            RDObj=createRDObj(sfObj,labelStringEdit,spaceLimit);

            if isempty(RDObj)
                return;
            end

            result=this.setResult(RDObj);

        end
    end
end


function RDObj=createRDObj(sfObj,higlightedText,inputParam)

    MAText=ModelAdvisor.Text(higlightedText);
    MAText.RetainReturn=true;
    MAText.RetainSpaceReturn=true;
    RDObj=ModelAdvisor.ResultDetail;
    ModelAdvisor.ResultDetail.setData(RDObj,'SID',sfObj,'Expression',MAText.emitHTML);
    RDObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0736_c_rec_action',inputParam);

end