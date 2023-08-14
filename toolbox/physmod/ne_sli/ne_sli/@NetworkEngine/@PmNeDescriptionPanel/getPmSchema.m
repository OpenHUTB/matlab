function[retStatus,pmSchema]=getPmSchema(hThis,~)













    mySchema.ClassName='NetworkEngine.PmNeDescriptionPanel';
    mySchema.Parameters.DescrText=hThis.DescrText;
    mySchema.Parameters.BlockTitle=hThis.BlockTitle;



    mySchema.Version='1.0.1';

    pmSchema=mySchema;
    retStatus=true;
end
