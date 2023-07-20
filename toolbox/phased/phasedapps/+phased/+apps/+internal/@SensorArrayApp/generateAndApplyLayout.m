function generateAndApplyLayout(obj,varargin)





    if strcmp(obj.Container,'ToolGroup')

        atgName=obj.ToolGroup.Name;
        matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop();
        listRatio=obj.ListRatio;


        matDsk.setDocumentArrangement(atgName,matDsk.TILED,java.awt.Dimension(3,1));


        matDsk.setDocumentColumnWidths(atgName,[listRatio,1-2*listRatio,listRatio]);


        loc1=com.mathworks.widgets.desk.DTLocation.create(0);


        if~varargin{1}
            paramFigLocation=matDsk.getClientLocation(obj.ParametersFig.Name);
            if~isempty(paramFigLocation)
                if paramFigLocation.getTile~=0
                    matDsk.setClientLocation(obj.ParametersFig.Name,atgName,loc1);
                end
            end
        end


        loc3=com.mathworks.widgets.desk.DTLocation.create(2);
        matDsk.setClientLocation(obj.ArrayCharacteristicFig.Name,atgName,loc3)


        loc2=com.mathworks.widgets.desk.DTLocation.create(1);
        figClients=getFiguresDropTargetHandler(obj.ToolGroup);

        for i=1:numel(figClients.CloseListeners)
            if~strcmp(figClients.CloseListeners(i).Source{1}.Tag,...
                {'arrayCharaFig','arrayParamsFig','subarrayparamsfig'})
                plotFigName=figClients.CloseListeners(i).Source{1}.Name;
                matDsk.setClientLocation(plotFigName,atgName,loc2);
            end
        end

        if~varargin{1}
            loc1=com.mathworks.widgets.desk.DTLocation.create(0);
            drawnow;

            if obj.IsSubarray&&obj.ToolStripDisplay.PartitionArrayButton.Value


                figure(obj.ParametersFig);
                figname=obj.SubarrayPartitionFig.Name;
                obj.SubarrayPartitionFig.Visible='on';
                drawnow;
                matDsk.setClientLocation(figname,atgName,loc1);
            end
        end


        if varargin{1}
            matDsk.setDocumentColumnWidths(atgName,[0.001,1-listRatio,listRatio]);
        end
    else
        layoutJSON=fileread(...
        fullfile(matlabroot,'toolbox','phased','phasedapps',...
        '+phased','+apps','+internal','sensorAppLayout.json'));
        obj.ToolGroup.Layout=jsondecode(layoutJSON);

        if obj.pFromSimulink
            obj.ToolGroup.Layout.documentLayout.columnWeights=[0,1];
        end
    end
end
