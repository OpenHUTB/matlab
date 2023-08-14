function AllpoleFilterBlock(obj)




    if isR2011aOrEarlier(obj.ver)

        blks=obj.findBlocksOfType('AllpoleFilter');
        numBlks=length(blks);
        if numBlks>0
            load_system('dsparch4');

            for idx=1:numBlks

                oldBlock=blks{idx};
                name=get_param(oldBlock,'Name');
                parent=get_param(oldBlock,'Parent');
                tempBlock=[parent,'/temp'];
                add_block('dspobslib/Digital Filter',tempBlock);

                decorations=getDecorationParams(oldBlock);
                mask={};

                if strcmpi(get_param(oldBlock,'CoefSource'),'Dialog parameters')
                    coefSrc='Specify via dialog';
                else
                    coefSrc='Input port(s)';
                end
                set_param(tempBlock,...
                'TypePopup','IIR (all poles)',...
                'AllpoleFiltStruct',get_param(oldBlock,'FilterStructure'),...
                'IC',get_param(oldBlock,'InitialStates'),...
                'DenCoeffs',get_param(oldBlock,'Coefficients'),...
                'CoeffSource',coefSrc);

                delete_block(oldBlock);
                add_block(tempBlock,[parent,'/',name],decorations{:},mask{:});
                delete_block(tempBlock);


                newRef='dspobslib/Digital Filter';
                oldRef='dsparch4/Digital Filter';
                obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);
            end
        end
    end


    function decorations=getDecorationParams(block)





        decorations={
        'Position',[];
        'Orientation',[];
        'ForegroundColor',[];
        'BackgroundColor',[];
        'DropShadow',[];
        'NamePlacement',[];
        'FontName',[];
        'FontSize',[];
        'FontWeight',[];
        'FontAngle',[];
        'ShowName',[]
        };

        for i=1:size(decorations,1)
            decorations{i,2}=get_param(block,decorations{i,1});
        end

        decorations=reshape(decorations',1,length(decorations(:)));


