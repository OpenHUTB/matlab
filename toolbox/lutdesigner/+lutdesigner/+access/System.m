classdef System<lutdesigner.access.Access

    methods
        function accessDescs=getSubAccessDescs(this)

            findSystemOptions={'FollowLinks','on'};




            mdlBlocks=find_system(this.Path,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            findSystemOptions{:},'BlockType','ModelReference');


            lutBlocks=lutdesigner.lutfinder.LookupTableFinder.findLookupTableBlocks(this.Path,findSystemOptions{:});


            lutControlSystems=setdiff(lutdesigner.lutfinder.LookupTableFinder.findLookupTableControlSystems(this.Path,findSystemOptions{:}),this.Path);


            leaves=unique(regexprep([mdlBlocks;lutBlocks;lutControlSystems],'\n',' '));


            accessDescs=lutdesigner.access.internal.getLookupTableControlAccessDescs(this);
            numAccessDescs=numel(accessDescs);
            addedAccessIdRecord=containers.Map;


            parentPath=this.Path;
            parentType=this.Type;
            for i=1:numel(leaves)
                if~this.containsByPath(parentPath,leaves{i})

                    parentPath=this.Path;
                    parentType=this.Type;
                end

                curPath=parentPath;
                curType=parentType;
                pathParts=this.extractPathParts(extractAfter(leaves{i},[parentPath,'/']));

                for d=1:numel(pathParts)
                    parentPath=curPath;
                    parentType=curType;

                    curPath=[parentPath,'/',pathParts{d}];
                    access=this.fromSimulinkComponent(curPath);
                    curType=access.Type;
                    accessId=access.getId();
                    if addedAccessIdRecord.isKey(accessId)
                        continue;
                    end

                    accessDesc=access.toDesc();
                    accessDesc.parentType=parentType;
                    [accessDescs,numAccessDescs]=appendAccessDescs(accessDescs,numAccessDescs,accessDesc);
                    addedAccessIdRecord(accessId)=true;

                    [accessDescs,numAccessDescs]=appendAccessDescs(accessDescs,numAccessDescs,...
                    lutdesigner.access.internal.getLookupTableControlAccessDescs(access));
                end
            end
            accessDescs(numAccessDescs+1:end)=[];
        end
    end
end

function[accessDescsBuffer,newNumAccessDescs]=appendAccessDescs(accessDescsBuffer,curNumAccessDescs,accessDescsToAppend)
    newNumAccessDescs=curNumAccessDescs+numel(accessDescsToAppend);
    if newNumAccessDescs>numel(accessDescsBuffer)

        accessDescsBuffer=[
        accessDescsBuffer;
        lutdesigner.access.Access.createDescArray([newNumAccessDescs,1])
        ];
    end
    accessDescsBuffer(curNumAccessDescs+1:newNumAccessDescs)=accessDescsToAppend;
end
