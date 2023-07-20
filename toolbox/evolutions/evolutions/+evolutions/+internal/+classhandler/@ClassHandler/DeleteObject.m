function DeleteObject(classObj)




    factory=evolutions.internal.session.SessionManager.getVisitorFactory;
    visitor=factory.getVisitor('Delete');
    evolutions.internal.classhandler.ClassHandler.visitObjects(classObj,visitor);
end
