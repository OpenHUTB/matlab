function[sps,Multimeter,NewNode]=MutualInductanceBlock(nl,sps,...
    Multimeter,NewNode)








    idx=nl.filter_type('Mutual Inductance');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        measure=get_param(block,'Measurements');
        TypeOfMutual=get_param(block,'TypeOfMutual');

        switch TypeOfMutual

        case 'Two or three windings with equal mutual terms'

            ThreeWindings=strcmp('on',get_param(block,'ThreeWindings'));
            [SelfImpedance1,SelfImpedance2,SelfImpedance3,MutualImpedance]=...
            getSPSmaskvalues(block,{'SelfImpedance1','SelfImpedance2',...
            'SelfImpedance3','MutualImpedance'});
            blocinit(block,{SelfImpedance1,SelfImpedance2,ThreeWindings,...
            SelfImpedance3,MutualImpedance});
            selfImpedances=[SelfImpedance1;SelfImpedance2];







            initNodes=nl.block_nodes(block);



            if ThreeWindings
                nbWindings=3;
                selfImpedances=[selfImpedances;SelfImpedance3];
                nodes=[initNodes([1,4]);initNodes([2,5]);initNodes([3,6]);];
            else
                nbWindings=2;
                nodes=[initNodes([1,3]);initNodes([2,4])];
            end

            BranchType=3;
            if MutualImpedance(1)==0&&MutualImpedance(2)==0

                BranchType=0;
                Rm=0;
                Lm=0;
            end

            if BranchType==3
                Rm=MutualImpedance(1);
                Lm=MutualImpedance(2)*1e3;
            end

            R=selfImpedances(:,1)';
            L=selfImpedances(:,2)'*1e3;


            for k=1:nbWindings
                if((abs(L(k))==abs(Lm))&&Lm~=0)
                    errorMessageInvalidValues(BlockNom,k,'Inductance');
                end
                if((abs(R(k))==abs(Rm))&&R(k)~=0)
                    errorMessageInvalidValues(BlockNom,k,'Resistance');
                end

                sps.rlc(end+1,1:6)=[nodes(k,1),nodes(k,2)...
                ,BranchType,R(k),L(k),0];
                sps.rlcnames{end+1}=['winding_',num2str(k),': ',BlockNom];

                x=size(sps.rlc,1);
                if strcmp('Winding voltages',measure)||...
                    strcmp('Winding voltages and currents',measure)
                    Multimeter.Yu(end+1,1:2)=sps.rlc(x,1:2);
                    Multimeter.V{end+1}=['Uw',num2str(k),': ',BlockNom];
                end
                if strcmp('Winding currents',measure)||...
                    strcmp('Winding voltages and currents',measure)
                    Multimeter.Yi{end+1,1}=x;
                    Multimeter.I{end+1}=['Iw',num2str(k),': ',BlockNom];
                end
            end


            RisZero=([R,Rm]==0);
            if(any(RisZero(1:end-1))&&~all(RisZero))
                erreur.identifier=...
                ['SpecializedPowerSystems:MutualInductanceBlock:',...
                'InvalidSelfResistance'];
                erreur.message=['Parameter error in ''',BlockNom,...
                ''' block. If any self-resistance value is set to ',...
                'zero, all self-resistances and magnetizing resistance',...
                ' must also be set to zero. Otherwise, all self-',...
                'resistances must be set to non-zero values.'];
                psberror(erreur);
            end



            if(any(L==0)&&Lm==0)
                erreur.identifier=...
                ['SpecializedPowerSystems:MutualInductanceBlock:',...
                'InvalidInductanceValues'];
                erreur.message=['Parameter error in ''',BlockNom,...
                ''' block. If any self-inductance value is set to ',...
                'zero, the magnetizing inductance can''t be zero.'];
                psberror(erreur);
            end


            if BranchType==3
                sps.rlc(end+1,1:6)=[NewNode,nodes(3+ThreeWindings),0,Rm,Lm,0];
                NewNode=NewNode+1;
                sps.rlcnames{end+1}=['mut: ',BlockNom];
            end


            if isfield(sps,'UnbalancedLoadFlow')
                if ThreeWindings
                    ResistanceMatrix=[R(1),Rm,Rm;Rm,R(2),Rm;Rm,Rm,R(3)];
                    InductanceMatrix=[L(1),Lm,Lm;Lm,L(2),Lm;Lm,Lm,L(3)];
                else
                    ResistanceMatrix=[R(1),Rm;Rm,R(2)];
                    InductanceMatrix=[L(1),Lm;Lm,L(2)];
                end
            end


        case 'Generalized mutual inductance'

            nbWindings=max(1,round(eval(get_param(block,...
            'NumberOfWindings'),'1')));
            [InductanceMatrix,ResistanceMatrix]=getSPSmaskvalues(...
            block,{'InductanceMatrix','ResistanceMatrix'});

            verifyRLMatrices(BlockNom,nbWindings,...
            InductanceMatrix,ResistanceMatrix);

            Nodes=nl.block_nodes(block);
            [sps,Multimeter,NewNode]=AddMutualInductanceDevice(BlockNom,...
            nbWindings,ResistanceMatrix,InductanceMatrix,Nodes,...
            NewNode,sps,Multimeter,measure);
        end

        if isfield(sps,'UnbalancedLoadFlow')

            if nbWindings<4

                initNodes=nl.block_nodes(block);

                sps.UnbalancedLoadFlow.Lines.handle{end+1}=block;
                sps.UnbalancedLoadFlow.Lines.r{end+1}=ResistanceMatrix;
                sps.UnbalancedLoadFlow.Lines.l{end+1}=InductanceMatrix;
                sps.UnbalancedLoadFlow.Lines.c{end+1}=[];
                sps.UnbalancedLoadFlow.Lines.long{end+1}=[];
                sps.UnbalancedLoadFlow.Lines.freq{end+1}=[];
                sps.UnbalancedLoadFlow.Lines.leftnodes{end+1}=initNodes(1:nbWindings);
                sps.UnbalancedLoadFlow.Lines.rightnodes{end+1}=initNodes(nbWindings+1:2*nbWindings);
                sps.UnbalancedLoadFlow.Lines.LeftbusNumber{end+1}=[];
                sps.UnbalancedLoadFlow.Lines.RightbusNumber{end+1}=[];
                sps.UnbalancedLoadFlow.Lines.isPI{end+1}=0;
                sps.UnbalancedLoadFlow.Lines.BlockType{end+1}='Lmut';

            end
        end


    end

    function verifyRLMatrices(BlockNom,N,L,R)

        [N1,N2]=size(R);
        [N3,N4]=size(L);
        if~(N1==N2&&N1==N3&&N1==N4)
            msg=['The R and L matrices must be square and they must have the ',...
            'same dimensions'];
            errorMessageInvalidRLMatrices(BlockNom,msg)
        end
        if N1<2
            msg='The dimension of R and L matrices must be greater than 1';
            errorMessageInvalidRLMatrices(BlockNom,msg)
        end
        if~all(all(R==R'))
            msg='Matrix R must be symmetrical';
            errorMessageInvalidRLMatrices(BlockNom,msg)
        end
        if~all(all(L==L'))
            msg='Matrix L must be symmetrical';
            errorMessageInvalidRLMatrices(BlockNom,msg)
        end
        if N1~=N
            msg=['Matrix R must have the same dimension as the specified ',...
            'number of windings'];
            errorMessageInvalidRLMatrices(BlockNom,msg)
        end
        if N3~=N
            msg=['Matrix L must have the same dimension as the specified ',...
            'number of windings'];
            errorMessageInvalidRLMatrices(BlockNom,msg)
        end

        if(any(diag(R)==0)&&~all(all(R==0)))
            erreur.identifier=...
            'SpecializedPowerSystems:MutualInductanceBlock:InvalidSelfResistance';
            erreur.message=['Parameter error in ''',BlockNom,...
            ''' block. Matrix R cannot have null elements on ',...
            'its diagonal while having nonzero elements ',...
            'elsehwere.'];
            psberror(erreur);
        end




        for k=1:N3
            if(L(k,k)==0&&all(L(k,:)==0)&&all(L(:,k)==0))
                erreur.identifier=...
                ['SpecializedPowerSystems:MutualInductanceBlock:',...
                'InvalidInductanceValues'];
                erreur.message=['Parameter error in ''',BlockNom,...
                ''' block. If any self-inductance value (on diagonal of ',...
                'inductance matrix) is set to zero, a non-zero value must ',...
                'be present on the corresponding row and column. '];
                psberror(erreur);
            end
        end


        verifyCouplingTerms(BlockNom,R,'Resistance');
        verifyCouplingTerms(BlockNom,L,'Inductance');


        function errorMessageInvalidRLMatrices(BlockNom,msg)
            erreur.identifier=...
            'SpecializedPowerSystems:MutualInductanceBlock:InvalidRLMatrices';
            erreur.message=['Parameter error in ''',BlockNom,''' block. ',msg];
            psberror(erreur);

            function errorMessageInvalidValues(BlockNom,windingNumber,name)
                nameLower=lower(name);
                wdgNumberStr=num2str(windingNumber);
                erreur.identifier=[...
                'SpecializedPowerSystems:MutualInductanceBlock:Invalid',name,'Values'];
                erreur.message=['Parameter error in ''',BlockNom,''' block, winding ',...
                wdgNumberStr,'. Self-',nameLower,' and mutual ',nameLower,...
                ' must have different absolute values.'];
                psberror(erreur);

                function verifyCouplingTerms(BlockNom,mat,name)
                    dim=size(mat,1);
                    for k=1:dim


                        self=abs(mat(k,k));
                        if(self~=0)
                            row=abs(mat(k,:));
                            row(k)=[];
                            col=abs(mat(:,k));
                            col(k)=[];
                            if any([row,col']==self)
                                errorMessageInvalidValues(BlockNom,num2str(k),name);
                            end
                        end
                    end