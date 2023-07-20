function obj=reloadv2tov3(obj)







    obj.SupportsAD=supportsAD(obj.Operator)&&obj.ExprLeft.SupportsAD&&...
    obj.ExprRight.SupportsAD;