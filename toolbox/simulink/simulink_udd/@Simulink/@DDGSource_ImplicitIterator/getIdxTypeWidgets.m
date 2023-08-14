function[indexmode_popup,indexdtype_popup]=getIdxTypeWidgets(this)






    indexmode_popup=this.initWidget('IndexMode',false);
    indexmode_popup.Tag='_Iteration_Index_Base_';
    indexmode_popup.RowSpan=[1,1];
    indexmode_popup.ColSpan=[1,1];


    indexdtype_popup=this.initWidget('IterationIndexDataType',false);
    indexdtype_popup.Tag='_Iteration_Index_Data_Type_';
    indexdtype_popup.RowSpan=[1,1];
    indexdtype_popup.ColSpan=[1,1];

end
