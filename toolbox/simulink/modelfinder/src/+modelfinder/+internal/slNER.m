classdef(Hidden)slNER






    properties(Constant,Access=protected)
        entities={'Non-Entity','Block-B','Block-I',...
        'Concept-B','Concept-I',...
        'Domain-B','Domain-I',...
        'Toolbox-B','Toolbox-I'};

        numEntities=length(modelfinder.internal.slNER.entities);

        posCategories=...
        {'adjective','adposition','adverb','auxiliary-verb'...
        ,'coord-conjunction','determiner','interjection'...
        ,'noun','numeral','particle','pronoun'...
        ,'proper-noun','punctuation','subord-conjunction'...
        ,'symbol','verb','other','special-keyword'};
    end

    methods(Static)
        function queryStruct=tagEntities(strQuery)











            persistent EmbNet;
            if(isempty(EmbNet))

                filePath=fullfile(matlabroot,'toolbox','simulink',...
                'modelfinder','db','EmbNet.mat');
                EmbNet.wordEmb=load(filePath,'wordEmb').wordEmb;
                EmbNet.posTagInfo=load(filePath,'posTagInfo').posTagInfo;
                EmbNet.net=load(filePath,'net').net;
            end

            [tblQuery,matLabels]=...
            modelfinder.internal.slNER.predictEntities(EmbNet,strQuery);


            queryStruct=...
            modelfinder.internal.slNER.parseResult(...
            matLabels,tblQuery.token);
        end
    end

    methods(Static,Access=protected)

        function[matWordEmb,matPOS]=annotatePrevNextFeatures(...
            EmbNet,tblDbQueries,windowSize)



            word_c=tblDbQueries.token;


            pos_c=tblDbQueries.posTag;


            emb_c=modelfinder.internal.slNER.myWord2vec(...
            EmbNet.wordEmb,word_c);


            numDimsEmb=EmbNet.wordEmb.Dimension;


            numDimsPOS=length(modelfinder.internal.slNER.posCategories);


            emb_replace=zeros(1,numDimsEmb);


            s_idx=word_c=='@start';
            e_idx=word_c=='@end';

            emb_c(s_idx,:)=repmat(emb_replace,[sum(s_idx),1]);
            emb_c(e_idx,:)=repmat(emb_replace,[sum(e_idx),1]);


            ohe_pos_c=modelfinder.internal.slNER.posCategories==pos_c;


            word_prev=word_c;
            word_next=word_c;


            emb_prev=emb_c;
            emb_next=emb_c;


            pos_prev=pos_c;
            pos_next=pos_c;


            ohe_pos_prev=ohe_pos_c;
            ohe_pos_next=ohe_pos_c;


            word_p_const=repmat("@start",size(word_c));
            word_n_const=repmat("@end",size(word_c));


            pos_const=categorical(repmat(...
            modelfinder.internal.slNER.posCategories(end),size(pos_c)));


            emb_const=zeros(size(emb_c));



            ohe_pos_replace=...
            modelfinder.internal.slNER.posCategories==categorical(...
            modelfinder.internal.slNER.posCategories(end));


            ohe_pos_const=repmat(ohe_pos_replace,[length(word_c),1]);


            for i=1:windowSize

                word_p=word_p_const;
                word_n=word_n_const;

                emb_p=emb_const;
                emb_n=emb_const;

                pos_p=pos_const;
                pos_n=pos_p;

                ohe_pos_p=ohe_pos_const;
                ohe_pos_n=ohe_pos_const;

                word_p(2:end)=word_prev(1:end-1,1);
                word_n(1:end-1)=word_next(2:end,i);

                emb_p(2:end,:)=emb_prev(1:end-1,1:numDimsEmb);
                emb_p_idx=(i-1)*numDimsEmb+1;
                emb_n(1:end-1,:)=emb_next(2:end,emb_p_idx:i*numDimsEmb);

                ohe_pos_p(2:end,:)=ohe_pos_prev(1:end-1,1:numDimsPOS);
                ohe_pos_p_idx=(i-1)*numDimsPOS+1;
                ohe_pos_n(1:end-1,:)=ohe_pos_next(2:end,ohe_pos_p_idx:i*numDimsPOS);

                pos_p(2:end)=pos_prev(1:end-1,1);
                pos_n(1:end-1)=pos_next(2:end,i);

                word_prev=[word_p,word_prev];
                word_next=[word_next,word_n];

                emb_prev=[emb_p,emb_prev];
                emb_next=[emb_next,emb_n];

                ohe_pos_prev=[ohe_pos_p,ohe_pos_prev];
                ohe_pos_next=[ohe_pos_next,ohe_pos_n];

                pos_prev=[pos_p,pos_prev];
                pos_next=[pos_next,pos_n];

                idxStart=find(word_prev(:,2)=="@start");
                idxEnd=find(word_next(:,i)=="@end");

                word_prev(idxStart,1)="@start";
                word_next(idxEnd,end)="@end";

                emb_prev(idxStart,1:numDimsEmb)=...
                repmat(emb_replace,[length(idxStart),1]);
                emb_next(idxEnd,end-numDimsEmb+1:end)=...
                repmat(emb_replace,[length(idxEnd),1]);

                ohe_pos_prev(idxStart,1:numDimsPOS)=...
                repmat(ohe_pos_replace,[length(idxStart),1]);
                ohe_pos_next(idxEnd,end-numDimsPOS+1:end)=...
                repmat(ohe_pos_replace,[length(idxEnd),1]);

                pos_prev(idxStart,1)='special-keyword';
                pos_next(idxEnd,end)='special-keyword';
            end

            matWordEmb=[emb_prev,emb_next(:,1+numDimsEmb:end)];

            matPOS=[ohe_pos_prev,ohe_pos_next(:,1+numDimsPOS:end)];
        end

        function[tblQuery,matLabels]=predictEntities(EmbNet,inputString)




            tblQuery=modelfinder.internal.slNER.processInputString(...
            EmbNet,inputString);


            [matWordEmb,matPOS]=...
            modelfinder.internal.slNER.annotatePrevNextFeatures(...
            EmbNet,tblQuery,3);


            matFeaturizedQuery=[matWordEmb,matPOS];


            matFeaturizedQuery(isnan(matFeaturizedQuery))=0;


            matProbabilities=...
            modelfinder.internal.slNER.netFcn(EmbNet,matFeaturizedQuery');


            [~,matLabels]=max(matProbabilities);

            tblQuery.entity=categorical(...
            modelfinder.internal.slNER.entities(matLabels)');

        end

        function tokenizedQuery=regexTokenize(query)








            tokenizedQuery=regexp(query,...
            "(\d*\.?\:?[\w@-])+(?:'\w+)?|[^\w\s]",...
            'match');
        end

        function[tokens,postable]=getPOSTags(EmbNet,query)


            posTagInfo=EmbNet.posTagInfo;


            model_data=posTagInfo.model_data;


            tokens=modelfinder.internal.slNER.regexTokenize(query);


            lower_toks=lower(tokens);
            toks=regexprep(lower_toks,'\d+','0');
            sent_num=ones(length(toks),1);
            old_pos_n=zeros(1,length(toks),'uint16');
            case_shape=modelfinder.internal.slNER.letterCaseShape(toks);
            dict_scores=modelfinder.internal.slNER.posDictionaryScores(toks,lower_toks,posTagInfo,case_shape);
            token_data={old_pos_n,sent_num,toks,lower_toks,...
            case_shape,dict_scores};


            pos_n=textanalytics.internal.predictPOS(...
            token_data,model_data,{});


            postable=posTagInfo.posTags(pos_n);
        end

        function queryStruct=parseResult(matLabels,tokenizedQuery)























            numTokens=length(matLabels);



            matLabels(tokenizedQuery=="block"|...
            tokenizedQuery=="blocks"|...
            tokenizedQuery=="domain")=1;




            if ismember(matLabels(1),[3,5,7,9])
                matLabels(1)=matLabels(1)-1;
            end


            for i=2:numTokens
                switch matLabels(i)
                case 3
                    if(~ismember(matLabels(i-1),[2,3]))

                        matLabels(i)=2;
                    end
                case 5
                    if(~ismember(matLabels(i-1),[4,5]))

                        matLabels(i)=4;
                    end
                case 7
                    if(~ismember(matLabels(i-1),[6,7]))

                        matLabels(i)=6;
                    end
                case 9

                    if(~ismember(matLabels(i-1),[8,9]))
                        matLabels(i)=8;
                    end
                end
            end



            block_count=0;
            concept_count=0;
            domain_count=0;
            toolbox_count=0;

            blocks={};
            concepts={};
            domains={};
            toolboxes={};

            for i=1:numTokens
                switch matLabels(i)
                case 1
                case 2
                    block_1=char(tokenizedQuery(i));
                    block_count=block_count+1;
                    blocks{block_count}=block_1;

                case 3
                    block_2=char(tokenizedQuery(i));
                    blocks{block_count}=[blocks{block_count},' ',block_2];

                case 4
                    concept_1=char(tokenizedQuery(i));
                    concept_count=concept_count+1;
                    concepts{concept_count}=concept_1;

                case 5
                    concept_2=char(tokenizedQuery(i));
                    concepts{concept_count}=[concepts{concept_count},' ',concept_2];

                case 6
                    domain_1=char(tokenizedQuery(i));
                    domain_count=domain_count+1;
                    domains{domain_count}=domain_1;

                case 7
                    domain_2=char(tokenizedQuery(i));
                    domains{domain_count}=[domains{domain_count},' ',domain_2];

                case 8
                    toolbox_1=char(tokenizedQuery(i));
                    toolbox_count=toolbox_count+1;
                    toolboxes{toolbox_count}=toolbox_1;

                case 9
                    toolbox_2=char(tokenizedQuery(i));
                    toolboxes{toolbox_count}=[toolboxes{toolbox_count},' ',toolbox_2];
                end
            end


            exprBefore='(\(|\[|\{)\s';
            exprAfter='\s(\)|\]|\})';

            exprCombined={exprBefore,exprAfter};
            exprReplace={'$1','$1'};

            blocks=regexprep(blocks,exprCombined,exprReplace);
            concepts=regexprep(concepts,exprCombined,exprReplace);
            domains=regexprep(domains,exprCombined,exprReplace);
            toolboxes=regexprep(toolboxes,exprCombined,exprReplace);

            queryStruct.blocks=blocks;
            queryStruct.concepts=concepts;
            queryStruct.domains=domains;
            queryStruct.toolboxes=toolboxes;


        end

        function tblQuery=processInputString(EmbNet,inputString)


            [token,posTag]=modelfinder.internal.slNER.getPOSTags(...
            EmbNet,inputString);
            token=["@start";token';"@end"];
            posTag=categorical(...
            ["special-keyword";posTag;"special-keyword"]);
            tblQuery=table(token,posTag);
        end

        function emb=myWord2vec(wordEmb,token)

            emb=NaN(length(token),wordEmb.Dimension);

            [token_idx,word_idx]=find(wordEmb.embVocabulary==token);
            emb(token_idx,:)=wordEmb.embValues(word_idx,:);
        end

        function matProbabilities=netFcn(EmbNet,matFeaturizedQuery)










%#ok<*RPMT0>


            net=EmbNet.net;

            x1_step1.keep=net.x1_step1.keep;
            x1_step2.xoffset=net.x1_step2.xoffset;
            x1_step2.gain=net.x1_step2.gain;
            x1_step2.ymin=net.x1_step2.ymin;


            b1=net.b1;
            IW1_1=net.IW1_1;


            b2=net.b2;
            LW2_1=net.LW2_1;




            Q=size(matFeaturizedQuery,2);


            xp1=removeconstantrows_apply(matFeaturizedQuery,x1_step1);
            xp1=mapminmax_apply(xp1,x1_step2);


            a1=tansig_apply(repmat(b1,1,Q)+IW1_1*xp1);


            a2=softmax_apply(repmat(b2,1,Q)+LW2_1*a1);


            matProbabilities=a2;




            function y=mapminmax_apply(x,settings)
                y=bsxfun(@minus,x,settings.xoffset);
                y=bsxfun(@times,y,settings.gain);
                y=bsxfun(@plus,y,settings.ymin);
            end


            function y=removeconstantrows_apply(x,settings)
                y=x(settings.keep,:);
            end


            function a=softmax_apply(n,~)
                if isa(n,'gpuArray')
                    a=iSoftmaxApplyGPU(n);
                else
                    a=iSoftmaxApplyCPU(n);
                end
            end
            function a=iSoftmaxApplyCPU(n)
                nmax=max(n,[],1);
                n=bsxfun(@minus,n,nmax);
                numerator=exp(n);
                denominator=sum(numerator,1);
                denominator(denominator==0)=1;
                a=bsxfun(@rdivide,numerator,denominator);
            end
            function a=iSoftmaxApplyGPU(n)
                nmax=max(n,[],1);
                numerator=arrayfun(@iSoftmaxApplyGPUHelper1,n,nmax);
                denominator=sum(numerator,1);
                a=arrayfun(@iSoftmaxApplyGPUHelper2,numerator,denominator);
            end
            function numerator=iSoftmaxApplyGPUHelper1(n,nmax)
                numerator=exp(n-nmax);
            end
            function a=iSoftmaxApplyGPUHelper2(numerator,denominator)
                if(denominator==0)
                    a=numerator;
                else
                    a=numerator./denominator;
                end
            end


            function a=tansig_apply(n,~)
                a=2./(1+exp(-2*n))-1;
            end
        end



        function letterShape=letterCaseShape(words)











            letterShape=strings(1,length(words));
            short_mask=strlength(words)<2;
            lower_words=lower(words);
            upper_words=upper(words);

            head=extractBefore(words,2);
            head_upper_cased=extractBefore(upper_words,2);
            tail=extractAfter(words,1);
            tail_lower_cased=extractAfter(lower_words,1);
            tail_upper_cased=extractAfter(upper_words,1);

            uncased=lower_words==upper_words;
            upper_head=head_upper_cased==head;
            lower_head=~upper_head;
            lower_tail=tail_lower_cased==tail;
            upper_tail=tail_upper_cased==tail;


            letterShape(~lower_tail)="xX_";
            letterShape(upper_head&upper_tail)="XX_";
            letterShape(upper_head&lower_tail)="Xx_";
            letterShape(upper_head&short_mask)="X_";
            letterShape(lower_head&lower_tail)="xx_";
            letterShape(uncased)="?_";
        end

        function scores=posDictionaryScores(tokens,lower_tokens,posTagInfo,case_shapes)






            dict=posTagInfo.dict;
            constants=posTagInfo.constants;
            if isempty(dict)
                scores=zeros(0,0,'uint8');
                return;
            end
            ntags=size(dict.scores,1);


            index=modelfinder.internal.slNER.lookupToken(tokens,dict.words.Vocabulary);
            scores=zeros(ntags,length(tokens),'uint8');
            known_word=index>0;
            scores(:,known_word)=dict.scores(:,index(known_word));


            const_index=modelfinder.internal.slNER.lookupToken(tokens,constants.words.Vocabulary);
            known_constant=const_index>0;
            ci=const_index(known_constant);
            const_tag=reshape(constants.tags(ci),[],1);
            const_word=reshape(find(known_constant),[],1);
            linIndex=sub2ind(size(scores),const_tag,const_word);
            scores(linIndex)=dict.max_group;

            known_word=known_word|known_constant;


            if~all(known_word)
                [known_word,scores]=modelfinder.internal.slNER.lookupLowerCase(known_word,lower_tokens,dict,scores);
            end

            if~all(known_word)
                scores=modelfinder.internal.slNER.lookupHyphenated(known_word,lower_tokens,dict,scores);
            end


            capitalized=startsWith(case_shapes,'X');


            properNoun=find(posTagInfo.posTags=="proper-noun");
            scores(properNoun,capitalized)=max(scores(properNoun,capitalized),1);
        end

        function[known_word,scores]=lookupLowerCase(known_word,lower_tokens,dict,scores)
            unknown_position=find(~known_word);
            lower_word=lower_tokens(unknown_position);
            lower_index=modelfinder.internal.slNER.lookupToken(lower_word,dict.words.Vocabulary);
            lower_known_word=lower_index>0;
            lhs_positions=unknown_position(lower_known_word);
            rhs_positions=lower_index(lower_known_word);
            scores(:,lhs_positions)=dict.scores(:,rhs_positions);
            known_word(lhs_positions)=true;
        end

        function scores=lookupHyphenated(known_word,tokens,dict,scores)
            has_hyphen=contains(tokens,'-');
            unknown_position=find(~known_word&has_hyphen);
            unknown_tokens=tokens(unknown_position);


            tail=extractAfter(unknown_tokens,'-');
            tail_index=modelfinder.internal.slNER.lookupToken(tail,dict.words.Vocabulary);
            tail_known_word=tail_index>0;
            lhs_positions=unknown_position(tail_known_word);
            rhs_positions=tail_index(tail_known_word);
            scores(:,lhs_positions)=dict.scores(:,rhs_positions);


            unhyphenated=erase(unknown_tokens,'-');
            hyphen_index=modelfinder.internal.slNER.lookupToken(unhyphenated,dict.words.Vocabulary);
            hyphen_known_word=hyphen_index>0;
            lhs_positions=unknown_position(hyphen_known_word);
            rhs_positions=hyphen_index(hyphen_known_word);
            scores(:,lhs_positions)=dict.scores(:,rhs_positions);
        end

        function index=lookupToken(tokens,vocabulary)
            index=zeros(size(tokens));
            [indexIdx,indexVals]=find(vocabulary==tokens');
            index(indexIdx)=indexVals;
        end
    end
end
