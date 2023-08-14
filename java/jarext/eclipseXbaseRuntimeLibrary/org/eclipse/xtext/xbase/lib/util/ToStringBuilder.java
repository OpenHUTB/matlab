// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ToStringBuilder.java

package org.eclipse.xtext.xbase.lib.util;

import com.google.common.base.Strings;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.*;
import org.eclipse.xtext.xbase.lib.Exceptions;

// Referenced classes of package org.eclipse.xtext.xbase.lib.util:
//            ToStringContext

public final class ToStringBuilder
{
    private static class IndentationAwareStringBuilder
    {

        public IndentationAwareStringBuilder increaseIndent()
        {
            indentation++;
            return this;
        }

        public IndentationAwareStringBuilder decreaseIndent()
        {
            indentation--;
            return this;
        }

        public IndentationAwareStringBuilder append(CharSequence string)
        {
            if(indentation > 0)
            {
                String indented = string.toString().replace("\n", (new StringBuilder()).append("\n").append(Strings.repeat("  ", indentation)).toString());
                builder.append(indented);
            } else
            {
                builder.append(string);
            }
            return this;
        }

        public IndentationAwareStringBuilder newLine()
        {
            builder.append("\n").append(getClass().repeat("  ", indentation));
            return this;
        }

        public String toString()
        {
            return builder.toString();
        }

        private final StringBuilder builder;
        private final String indentationString = "  ";
        private final String newLineString = "\n";
        private int indentation;

        private IndentationAwareStringBuilder()
        {
            builder = new StringBuilder();
            indentation = 0;
        }

    }

    private static final class Part
    {

        private String fieldName;
        private Object value;





        private Part()
        {
        }

    }


    public ToStringBuilder(Object instance)
    {
        multiLine = true;
        skipNulls = false;
        showFieldNames = true;
        prettyPrint = true;
        this.instance = instance;
        typeName = instance.getClass().getSimpleName();
    }

    public ToStringBuilder singleLine()
    {
        multiLine = false;
        return this;
    }

    public ToStringBuilder skipNulls()
    {
        skipNulls = true;
        return this;
    }

    public ToStringBuilder hideFieldNames()
    {
        showFieldNames = false;
        return this;
    }

    public ToStringBuilder verbatimValues()
    {
        prettyPrint = false;
        return this;
    }

    public ToStringBuilder addDeclaredFields()
    {
        Field fields[] = instance.getClass().getDeclaredFields();
        Field afield[] = fields;
        int i = afield.length;
        for(int j = 0; j < i; j++)
        {
            Field field = afield[j];
            addField(field);
        }

        return this;
    }

    public ToStringBuilder addAllFields()
    {
        List fields = getAllDeclaredFields(instance.getClass());
        Field field;
        for(Iterator iterator = fields.iterator(); iterator.hasNext(); addField(field))
            field = (Field)iterator.next();

        return this;
    }

    public ToStringBuilder addField(String fieldName)
    {
        List fields = getAllDeclaredFields(instance.getClass());
        Iterator iterator = fields.iterator();
        do
        {
            if(!iterator.hasNext())
                break;
            Field field = (Field)iterator.next();
            if(!fieldName.equals(field.getName()))
                continue;
            addField(field);
            break;
        } while(true);
        return this;
    }

    private ToStringBuilder addField(Field field)
    {
        if(!Modifier.isStatic(field.getModifiers()))
        {
            field.setAccessible(true);
            try
            {
                add(field.getName(), field.get(instance));
            }
            catch(IllegalAccessException e)
            {
                throw Exceptions.sneakyThrow(e);
            }
        }
        return this;
    }

    public ToStringBuilder add(String fieldName, Object value)
    {
        return addPart(fieldName, value);
    }

    public ToStringBuilder add(Object value)
    {
        return addPart(value);
    }

    private Part addPart()
    {
        Part p = new Part();
        parts.add(p);
        return p;
    }

    private ToStringBuilder addPart(Object value)
    {
        Part p = addPart();
        p.value = value;
        return this;
    }

    private ToStringBuilder addPart(String fieldName, Object value)
    {
        Part p = addPart();
        p.fieldName = fieldName;
        p.value = value;
        return this;
    }

    public String toString()
    {
        boolean startProcessing = toStringContext.startProcessing(instance);
        if(!startProcessing)
            return toSimpleReferenceString(instance);
        Object obj;
        IndentationAwareStringBuilder builder = new IndentationAwareStringBuilder();
        builder.append(typeName).append(" ");
        builder.append("[");
        String nextSeparator = "";
        if(multiLine)
            builder.increaseIndent();
        obj = parts.iterator();
        do
        {
            if(!((Iterator) (obj)).hasNext())
                break;
            Part part = (Part)((Iterator) (obj)).next();
            if(!skipNulls || part.value != null)
            {
                if(multiLine)
                {
                    builder.newLine();
                } else
                {
                    builder.append(nextSeparator);
                    nextSeparator = ", ";
                }
                if(part.fieldName != null && showFieldNames)
                    builder.append(part.fieldName).append(" = ");
                internalToString(part.value, builder);
            }
        } while(true);
        if(multiLine)
            builder.decreaseIndent().newLine();
        builder.append("]");
        obj = builder.toString();
        toStringContext.endProcessing(instance);
        return ((String) (obj));
        Exception exception;
        exception;
        toStringContext.endProcessing(instance);
        throw exception;
    }

    private void internalToString(Object object, IndentationAwareStringBuilder sb)
    {
        if(prettyPrint)
        {
            if(object instanceof Iterable)
                serializeIterable((Iterable)object, sb);
            else
            if(object instanceof Object[])
                sb.append(Arrays.toString((Object[])(Object[])object));
            else
            if(object instanceof byte[])
                sb.append(Arrays.toString((byte[])(byte[])object));
            else
            if(object instanceof char[])
                sb.append(Arrays.toString((char[])(char[])object));
            else
            if(object instanceof int[])
                sb.append(Arrays.toString((int[])(int[])object));
            else
            if(object instanceof boolean[])
                sb.append(Arrays.toString((boolean[])(boolean[])object));
            else
            if(object instanceof long[])
                sb.append(Arrays.toString((long[])(long[])object));
            else
            if(object instanceof float[])
                sb.append(Arrays.toString((float[])(float[])object));
            else
            if(object instanceof double[])
                sb.append(Arrays.toString((double[])(double[])object));
            else
            if(object instanceof CharSequence)
                sb.append("\"").append(((CharSequence)object).toString().replace("\n", "\\n").replace("\r", "\\r")).append("\"");
            else
            if(object instanceof Enum)
                sb.append(((Enum)object).name());
            else
                sb.append(String.valueOf(object));
        } else
        {
            sb.append(String.valueOf(object));
        }
    }

    private void serializeIterable(Iterable object, IndentationAwareStringBuilder sb)
    {
        Iterator iterator = object.iterator();
        sb.append(object.getClass().getSimpleName()).append(" (");
        if(multiLine)
            sb.increaseIndent();
        boolean wasEmpty = true;
        do
        {
            if(!iterator.hasNext())
                break;
            wasEmpty = false;
            if(multiLine)
                sb.newLine();
            internalToString(iterator.next(), sb);
            if(iterator.hasNext())
                sb.append(",");
        } while(true);
        if(multiLine)
            sb.decreaseIndent();
        if(!wasEmpty && multiLine)
            sb.newLine();
        sb.append(")");
    }

    private String toSimpleReferenceString(Object obj)
    {
        String simpleName = obj.getClass().getSimpleName();
        int identityHashCode = System.identityHashCode(obj);
        return (new StringBuilder()).append(simpleName).append("@").append(Integer.valueOf(identityHashCode)).toString();
    }

    private List getAllDeclaredFields(Class clazz)
    {
        ArrayList result = new ArrayList();
        for(Class current = clazz; current != null; current = current.getSuperclass())
        {
            Field declaredFields[] = current.getDeclaredFields();
            result.addAll(Arrays.asList(declaredFields));
        }

        return result;
    }

    private static ToStringContext toStringContext;
    private final Object instance;
    private final String typeName;
    private boolean multiLine;
    private boolean skipNulls;
    private boolean showFieldNames;
    private boolean prettyPrint;
    private final List parts = new ArrayList();

    static 
    {
        toStringContext = ToStringContext.INSTANCE;
    }
}
