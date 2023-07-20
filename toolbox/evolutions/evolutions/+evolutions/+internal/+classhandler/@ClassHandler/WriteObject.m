function WriteObject(classObj)




    factory=evolutions.internal.session.SessionManager.getVisitorFactory;
    visitor=factory.getVisitor('Write');
    evolutions.internal.classhandler.ClassHandler.visitObjects(classObj,visitor);
end
