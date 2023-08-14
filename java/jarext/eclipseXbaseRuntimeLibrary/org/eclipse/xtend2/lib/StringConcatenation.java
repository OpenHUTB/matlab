// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   StringConcatenation.java

package org.eclipse.xtend2.lib;

import java.util.*;

// Referenced classes of package org.eclipse.xtend2.lib:
//            StringConcatenationClient, WhitespaceMatcher, DefaultLineDelimiter

public class StringConcatenation
    implements CharSequence
{
    private static class IndentedTarget extends SimpleTarget
    {

        public void newLineIfNotEmpty()
        {
            super.newLineIfNotEmpty();
            super.append(indentation);
        }

        public void newLine()
        {
            super.newLine();
            super.append(indentation);
        }

        public void appendImmediate(Object object, String indentation)
        {
            super.appendImmediate(object, (new StringBuilder()).append(this.indentation).append(indentation).toString());
        }

        public void append(Object object, String indentation)
        {
            super.append(object, (new StringBuilder()).append(this.indentation).append(indentation).toString());
        }

        public void append(Object object)
        {
            super.append(object, indentation);
        }

        private final String indentation;

        private IndentedTarget(StringConcatenation target, String indentation, int index)
        {
            super(target, index);
            this.indentation = indentation;
        }

    }

    private static class SimpleTarget
        implements StringConcatenationClient.TargetStringConcatenation
    {

        public int length()
        {
            return target.length();
        }

        public char charAt(int index)
        {
            return target.charAt(index);
        }

        public CharSequence subSequence(int start, int end)
        {
            return target.subSequence(start, end);
        }

        public void newLineIfNotEmpty()
        {
            target.newLineIfNotEmpty();
        }

        public void newLine()
        {
            target.newLine();
        }

        public void appendImmediate(Object object, String indentation)
        {
            target.appendImmediate(object, indentation);
        }

        public void append(Object object, String indentation)
        {
            if(offsetFixup == 0)
                target.append(object, indentation);
            else
                target.append(object, indentation, target.segments.size() - offsetFixup);
        }

        public void append(Object object)
        {
            target.append(object, target.segments.size() - offsetFixup);
        }

        private final StringConcatenation target;
        private final int offsetFixup;

        private SimpleTarget(StringConcatenation target, int index)
        {
            this.target = target;
            offsetFixup = target.segments.size() - index;
        }

    }


    public StringConcatenation()
    {
        this(DEFAULT_LINE_DELIMITER);
    }

    public StringConcatenation(String lineDelimiter)
    {
        segments = new ArrayList(48);
        lastSegmentsSize = 48;
        if(lineDelimiter == null || lineDelimiter.length() == 0)
        {
            throw new IllegalArgumentException("lineDelimiter must not be null or empty");
        } else
        {
            this.lineDelimiter = lineDelimiter;
            return;
        }
    }

    private void growSegments(int increment)
    {
        int targetSize = segments.size() + increment;
        if(targetSize <= lastSegmentsSize)
            return;
        int mod = targetSize % 16;
        if(mod != 0)
            targetSize += 16 - mod;
        segments.ensureCapacity(targetSize);
        lastSegmentsSize = targetSize;
    }

    public void append(Object object)
    {
        append(object, segments.size());
    }

    public void append(String str)
    {
        if(str != null)
            append(str, segments.size());
    }

    public void append(StringConcatenation concat)
    {
        if(concat != null)
            appendSegments(segments.size(), concat.getSignificantContent(), concat.lineDelimiter);
    }

    public void append(StringConcatenationClient client)
    {
        if(client != null)
            client.appendTo(new SimpleTarget(this, segments.size()));
    }

    protected void append(Object object, int index)
    {
        if(object == null)
            return;
        if(object instanceof String)
            append((String)object, index);
        else
        if(object instanceof StringConcatenation)
        {
            StringConcatenation other = (StringConcatenation)object;
            appendSegments(index, other.getSignificantContent(), other.lineDelimiter);
        } else
        if(object instanceof StringConcatenationClient)
        {
            StringConcatenationClient other = (StringConcatenationClient)object;
            other.appendTo(new SimpleTarget(this, index));
        } else
        {
            String text = getStringRepresentation(object);
            if(text != null)
                append(text, index);
        }
    }

    private void append(String text, int index)
    {
        int initial = initialSegmentSize(text);
        if(initial == text.length())
            appendSegment(index, text);
        else
            appendSegments(index, continueSplitting(text, initial));
    }

    public void append(Object object, String indentation)
    {
        append(object, indentation, segments.size());
    }

    public void append(String str, String indentation)
    {
        if(indentation.isEmpty())
            append(str);
        else
        if(str != null)
            append(indentation, str, segments.size());
    }

    public void append(StringConcatenation concat, String indentation)
    {
        if(indentation.isEmpty())
            append(concat);
        else
        if(concat != null)
            appendSegments(indentation, segments.size(), concat.getSignificantContent(), concat.lineDelimiter);
    }

    public void append(StringConcatenationClient client, String indentation)
    {
        if(indentation.isEmpty())
            append(client);
        else
        if(client != null)
            client.appendTo(new IndentedTarget(this, indentation, segments.size()));
    }

    protected void append(Object object, String indentation, int index)
    {
        if(indentation.length() == 0)
        {
            append(object, index);
            return;
        }
        if(object == null)
            return;
        if(object instanceof String)
            append(indentation, (String)object, index);
        else
        if(object instanceof StringConcatenation)
        {
            StringConcatenation other = (StringConcatenation)object;
            List otherSegments = other.getSignificantContent();
            appendSegments(indentation, index, otherSegments, other.lineDelimiter);
        } else
        if(object instanceof StringConcatenationClient)
        {
            StringConcatenationClient other = (StringConcatenationClient)object;
            other.appendTo(new IndentedTarget(this, indentation, index));
        } else
        {
            String text = getStringRepresentation(object);
            if(text != null)
                append(indentation, text, index);
        }
    }

    private void append(String indentation, String text, int index)
    {
        int initial = initialSegmentSize(text);
        if(initial == text.length())
            appendSegment(index, text);
        else
            appendSegments(indentation, index, continueSplitting(text, initial), lineDelimiter);
    }

    protected String getStringRepresentation(Object object)
    {
        return object.toString();
    }

    public void appendImmediate(Object object, String indentation)
    {
        for(int i = segments.size() - 1; i >= 0; i--)
        {
            String segment = (String)segments.get(i);
            for(int j = 0; j < segment.length(); j++)
                if(!WhitespaceMatcher.isWhitespace(segment.charAt(j)))
                {
                    append(object, indentation, i + 1);
                    return;
                }

        }

        append(object, indentation, 0);
    }

    protected void appendSegments(String indentation, int index, List otherSegments, String otherDelimiter)
    {
        if(otherSegments.isEmpty())
            return;
        growSegments(otherSegments.size());
        for(Iterator iterator = otherSegments.iterator(); iterator.hasNext();)
        {
            String otherSegment = (String)iterator.next();
            if(otherDelimiter.equals(otherSegment))
            {
                segments.add(index++, lineDelimiter);
                segments.add(index++, indentation);
            } else
            {
                segments.add(index++, otherSegment);
            }
        }

        cachedToString = null;
    }

    protected void appendSegments(int index, List otherSegments, String otherDelimiter)
    {
        if(otherDelimiter.equals(lineDelimiter))
        {
            appendSegments(index, otherSegments);
        } else
        {
            if(otherSegments.isEmpty())
                return;
            growSegments(otherSegments.size());
            for(Iterator iterator = otherSegments.iterator(); iterator.hasNext();)
            {
                String otherSegment = (String)iterator.next();
                if(otherDelimiter.equals(otherSegment))
                    segments.add(index++, lineDelimiter);
                else
                    segments.add(index++, otherSegment);
            }

            cachedToString = null;
        }
    }

    protected void appendSegments(int index, List otherSegments)
    {
        growSegments(otherSegments.size());
        if(segments.addAll(index, otherSegments))
            cachedToString = null;
    }

    private void appendSegment(int index, String segment)
    {
        growSegments(1);
        segments.add(index, segment);
        cachedToString = null;
    }

    public void newLine()
    {
        growSegments(1);
        segments.add(lineDelimiter);
        cachedToString = null;
    }

    public void newLineIfNotEmpty()
    {
        for(int i = segments.size() - 1; i >= 0; i--)
        {
            String segment = (String)segments.get(i);
            if(lineDelimiter.equals(segment))
            {
                segments.subList(i + 1, segments.size()).clear();
                cachedToString = null;
                return;
            }
            for(int j = 0; j < segment.length(); j++)
                if(!WhitespaceMatcher.isWhitespace(segment.charAt(j)))
                {
                    newLine();
                    return;
                }

        }

        segments.clear();
        cachedToString = null;
    }

    public String toString()
    {
        if(cachedToString != null)
            return cachedToString;
        List significantContent = getSignificantContent();
        StringBuilder builder = new StringBuilder(significantContent.size() * 4);
        String segment;
        for(Iterator iterator = significantContent.iterator(); iterator.hasNext(); builder.append(segment))
            segment = (String)iterator.next();

        cachedToString = builder.toString();
        return cachedToString;
    }

    protected final List getContent()
    {
        return segments;
    }

    protected List getSignificantContent()
    {
        for(int i = segments.size() - 1; i >= 0; i--)
        {
            String segment = (String)segments.get(i);
            if(lineDelimiter.equals(segment))
                return segments.subList(0, i + 1);
            for(int j = 0; j < segment.length(); j++)
                if(!WhitespaceMatcher.isWhitespace(segment.charAt(j)))
                    return segments;

        }

        return segments;
    }

    protected String getLineDelimiter()
    {
        return lineDelimiter;
    }

    public int length()
    {
        return toString().length();
    }

    public char charAt(int index)
    {
        return toString().charAt(index);
    }

    public CharSequence subSequence(int start, int end)
    {
        return toString().subSequence(start, end);
    }

    protected List splitLinesAndNewLines(String text)
    {
        if(text == null)
            return Collections.emptyList();
        int idx = initialSegmentSize(text);
        if(idx == text.length())
            return Collections.singletonList(text);
        else
            return continueSplitting(text, idx);
    }

    private static int initialSegmentSize(String text)
    {
        int length = text.length();
        int idx = 0;
        do
        {
            if(idx >= length)
                break;
            char currentChar = text.charAt(idx);
            if(currentChar == '\r' || currentChar == '\n')
                break;
            idx++;
        } while(true);
        return idx;
    }

    private List continueSplitting(String text, int idx)
    {
        int length = text.length();
        int nextLineOffset = 0;
        List result = new ArrayList(5);
        for(; idx < length; idx++)
        {
            char currentChar = text.charAt(idx);
            if(currentChar == '\r')
            {
                int delimiterLength = 1;
                if(idx + 1 < length && text.charAt(idx + 1) == '\n')
                {
                    delimiterLength++;
                    idx++;
                }
                int lineLength = (idx - delimiterLength - nextLineOffset) + 1;
                result.add(text.substring(nextLineOffset, nextLineOffset + lineLength));
                result.add(lineDelimiter);
                nextLineOffset = idx + 1;
                continue;
            }
            if(currentChar == '\n')
            {
                int lineLength = idx - nextLineOffset;
                result.add(text.substring(nextLineOffset, nextLineOffset + lineLength));
                result.add(lineDelimiter);
                nextLineOffset = idx + 1;
            }
        }

        if(nextLineOffset != length)
        {
            int lineLength = length - nextLineOffset;
            result.add(text.substring(nextLineOffset, nextLineOffset + lineLength));
        }
        return result;
    }

    public static final String DEFAULT_LINE_DELIMITER = DefaultLineDelimiter.get();
    private static final int SEGMENTS_SIZE_INCREMENT = 16;
    private static final int SEGMENTS_INITIAL_SIZE = 48;
    private final ArrayList segments;
    private int lastSegmentsSize;
    private String cachedToString;
    private final String lineDelimiter;


}
