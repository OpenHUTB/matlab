function[jacStruct,hessStruct]=compileHessianReverse(obj,...
    jacStruct,hessStruct)
























    stack=obj.Stack;
    for i=numel(stack):-1:1

        Node=stack{i};




        [jacStruct,hessStruct]=compileHessianReverse(Node,jacStruct,hessStruct);
    end




end
