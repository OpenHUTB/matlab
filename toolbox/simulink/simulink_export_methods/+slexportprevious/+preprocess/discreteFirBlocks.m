function discreteFirBlocks(obj)












    if isR2008bOrEarlier(obj.ver)
        discreteFIRFilterBlks=slexportprevious.utils.findBlockType(obj.modelName,'DiscreteFir');

        if~isempty(discreteFIRFilterBlks)

            obsoleteLib='simulink_need_slupdate';
            load_system(obsoleteLib);
            sfuncWeightedMovingAverageBlk=[obsoleteLib,'/Weighted Moving Average'];


            verSP=ver('dsp');
            SPBlksetInstalled=isequal(verSP.Name,'DSP System Toolbox');
            if(SPBlksetInstalled)
                spblklib='dsparch4';
                load_system(spblklib);
                sfuncDigitalFilterBlk=[spblklib,'/Digital Filter'];
            else

                tempSys=getTempMdl(obj);
                blockType=['Discrete FIR',10,'Filter Block'];
            end


            for i=1:length(discreteFIRFilterBlks)
                blk=discreteFIRFilterBlks{i};




                mFIRFiltStruct=get_param(blk,'FirFiltStruct');
                mCoeffsource=get_param(blk,'CoefSource');
                mNumCoeff=get_param(blk,'NumCoeffs');

                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');

                if(~SPBlksetInstalled)
                    ports=get_param(blk,'Ports');
                    replacementBlock=createEmptySubsystem(obj,tempSys,blockType,ports);
                    delblk=onCleanup(@()delete_block(replacementBlock));
                end


                switch mFIRFiltStruct
                case 'Direct form'




                    if isR2007bOrEarlier(obj.ver)
                        mCoeffsource=get_param(blk,'CoefSource');
                        switch mCoeffsource
                        case 'Dialog parameters'
                            delete_block(blk);
                            add_block(sfuncWeightedMovingAverageBlk,blk,...
                            'mgainval',mNumCoeff,...
                            'Orientation',orient,...
                            'Position',pos);

                        case 'Input port'
                            delete_block(blk);
                            if(SPBlksetInstalled)
                                add_block(sfuncDigitalFilterBlk,blk,...
                                'TypePopup','FIR (all zeros)',...
                                'FIRFiltStruct',mFIRFiltStruct,...
                                'CoeffSource','Input port(s)',...
                                'NumCoeffs',mNumCoeff,...
                                'Orientation',orient,...
                                'Position',pos);
                            else

                                add_block(replacementBlock,blk,...
                                'Orientation',orient,...
                                'Position',pos);

                            end
                        end
                    end

                case{'Direct form symmetric','Direct form antisymmetric',...
                    'Direct form transposed','Lattice MA'}

                    switch mCoeffsource
                    case 'Dialog parameters'
                        mCoeffsource='Specify via dialog';
                    case 'Input port'
                        mCoeffsource='Input port(s)';
                    end

                    delete_block(blk);
                    if(SPBlksetInstalled)
                        add_block(sfuncDigitalFilterBlk,blk,...
                        'TypePopup','FIR (all zeros)',...
                        'FIRFiltStruct',mFIRFiltStruct,...
                        'CoeffSource',mCoeffsource,...
                        'NumCoeffs',mNumCoeff,...
                        'LatticeCoeffs',mNumCoeff,...
                        'Orientation',orient,...
                        'Position',pos);
                    else

                        add_block(replacementBlock,blk,...
                        'Orientation',orient,...
                        'Position',pos);
                    end

                end
            end


            close_system(obsoleteLib,0);
        end
    end
