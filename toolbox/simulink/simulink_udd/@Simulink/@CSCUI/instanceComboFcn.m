function instanceComboFcn(hUI,hObj,widgetTag,entryIdx,entries)





    if~isnumeric(entryIdx)
        DAStudio.error('Simulink:dialog:CSCUIInstComboUnexpectedArgType',class(entryIdx));
    end

    entryStr=entries{entryIdx+1};
    isInstanceSpecific=strcmp(entryStr,'Instance specific');

    switch widgetTag
    case 'tcscMsCombo'













        hObj.IsMemorySectionInstanceSpecific=isInstanceSpecific;
        if isInstanceSpecific
            hObj.MemorySection='Default';
        else
            hObj.MemorySection=entryStr;
        end

    case 'tcscScopeCombo'
        hObj.IsDataScopeInstanceSpecific=isInstanceSpecific;
        if isInstanceSpecific
            hObj.DataScope='Auto';
        else
            hObj.DataScope=entryStr;

            if strcmp(entryStr,'File')

                hObj.IsHeaderFileInstanceSpecific=false;
                hObj.HeaderFile='';

            elseif strcmp(entryStr,'Imported')

                if(strcmp(hObj.DataInit,'Static')&&...
                    ~hObj.IsDataInitInstanceSpecific)
                    hObj.DataInit='Auto';
                end

            else

                hObj.IsDataAccessInstanceSpecific=false;
                hObj.DataAccess='Direct';
            end
        end

    case 'tcscInitCombo'
        hObj.IsDataInitInstanceSpecific=isInstanceSpecific;
        if isInstanceSpecific
            hObj.DataInit='None';
        else
            hObj.DataInit=entryStr;

            if strcmp(entryStr,'Macro')

                hObj.IsMemorySectionInstanceSpecific=false;
                hObj.MemorySection='Default';


                hObj.IsDataAccessInstanceSpecific=false;
                hObj.DataAccess='Direct';
            end
        end

    case 'tcscAccessCombo'
        hObj.IsDataAccessInstanceSpecific=isInstanceSpecific;
        if isInstanceSpecific
            hObj.DataAccess='Direct';
        else
            hObj.DataAccess=entryStr;
        end

    case 'tcscHeaderCombo'
        hObj.IsHeaderFileInstanceSpecific=isInstanceSpecific;


    case 'tcscOwnerCombo'
        hObj.IsOwnerInstanceSpecific=isInstanceSpecific;


    case 'tcscPreserveDimensionsCombo'
        if strcmp(entryStr,'Instance specific')
            hObj.PreserveDimensionsInstanceSpecific=true;
            hObj.PreserveDimensions=false;
        else
            hObj.PreserveDimensionsInstanceSpecific=false;
            hObj.PreserveDimensions=strcmp(entryStr,'Yes');
        end

    case 'tcscDefnFileCombo'
        hObj.IsDefinitionFileInstanceSpecific=isInstanceSpecific;


    case 'tcscLatchingCombo'
        hObj.IsLatchingInstanceSpecific=isInstanceSpecific;
        if isInstanceSpecific
            hObj.Latching='None';
        else
            hObj.Latching=entryStr;
        end

    case 'tcscIsReusableCombo'
        hObj.IsReusableInstanceSpecific=isInstanceSpecific;
        if isInstanceSpecific
            hObj.IsReusable=false;
        else
            hObj.IsReusable=strcmp(entryStr,'Yes');
        end

    case 'tcscStructNameCombo'
        hAttribsObj=hObj.CSCTypeAttributes;
        hAttribsObj.IsStructNameInstanceSpecific=isInstanceSpecific;


    case 'tcscGetFunctionCombo'
        hAttribsObj=hObj.CSCTypeAttributes;
        hAttribsObj.IsGetFunctionInstanceSpecific=isInstanceSpecific;


    case 'tcscSetFunctionCombo'
        hAttribsObj=hObj.CSCTypeAttributes;
        hAttribsObj.IsSetFunctionInstanceSpecific=isInstanceSpecific;


    otherwise
        DAStudio.error('Simulink:dialog:CSCUIInstComboInvalidWidgetTag',widgetTag);
    end


    hUI.IsDirty=true;



