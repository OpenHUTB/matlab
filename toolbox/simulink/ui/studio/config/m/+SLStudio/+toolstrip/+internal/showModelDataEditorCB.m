



function showModelDataEditorCB(userdata,cbinfo)

    studio=cbinfo.studio;




    tokens=strsplit(userdata);


    comp=studio.getComponent('GLUE2:SpreadSheet','ModelData');
    if length(tokens)<2
        if isempty(comp)

            DataView.createSpreadSheetComponent(cbinfo.studio,true,false);
        elseif~comp.isVisible

            studio.showComponent(comp);
            studio.focusComponent(comp);
        else

            studio.hideComponent(comp);
        end
    else
        if isempty(comp)||~comp.isVisible

            DataView.showModelData(studio,'ModelData',tokens{1},DAStudio.message(tokens{2}));
        else
            studio.hideComponent(comp);
        end
    end
end
