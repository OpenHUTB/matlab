function setValue(self,Dialog,FieldName,Value)
    Dialog.(FieldName).Value=Value;
    e.EventName='ValueChanged';
    e.Source=Dialog.(FieldName);
    e.Source.Tag=Dialog.(FieldName).Tag;
    Dialog.(FieldName).ValueChangedFcn(self,e);
end