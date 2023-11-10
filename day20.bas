' It is practically impossible to teach good programming to students that
' have had a prior exposure to BASIC: as potential programmers they are
' mentally mutilated beyond hope of regeneration.
'   -- Edsger W. Dijkstra

' Subroutine and Type declarations
Type ListNode
    value As Integer<64>
    ' prevn and nextn are indices into inputList
    prevn As Integer
    nextn As Integer
End Type

' Globals
Dim Shared inputListP1() As ListNode
Dim Shared inputListP2() As ListNode
Const globalListLength = 5000
Const fileName = "input20.txt"
'Const globalListLength = 7
'Const fileName = "input20.test"

' Input functions
Sub populateInputLists
    Dim s As String
    Redim inputListP1(1 To globalListLength)
    Redim inputListP2(1 To globalListLength)
    Open fileName For Input As #1
    For i As Integer = 1 To globalListLength
        Line Input #1, s
        inputListP1(i).value = Vallng(s)
        inputListP2(i).value = Vallng(s) * 811589153
        inputListP1(i).nextn = i + 1
        inputListP2(i).nextn = i + 1
        inputListP1(i).prevn = i - 1
        inputListP2(i).prevn = i - 1
    Next i
    Close #1
    inputListP1(1).prevn = globalListLength
    inputListP2(1).prevn = globalListLength
    inputListP1(globalListLength).nextn = 1
    inputListP2(globalListLength).nextn = 1
End Sub

' List manipulation functions
Sub extractIndex( list() As ListNode, index As Integer )
    ' Removes inputList[index] from the doubly-linked list
    list(list(index).prevn).nextn = list(index).nextn
    list(list(index).nextn).prevn = list(index).prevn
End Sub

Sub insertJustBefore( list() as ListNode, src as Integer, dest As Integer )
    ' Inserts inputList[src] just before inputList[dest]
    list(list(dest).prevn).nextn = src
    list(src).prevn = list(dest).prevn
    list(dest).prevn = src
    list(src).nextn = dest
End Sub

Sub mixOneNode( list() As ListNode, index As Integer )
    'Print "Moving node with value " & list(index).value
    Dim moveCount As Integer = list(index).value Mod globalListLength
    If moveCount < 0 Then moveCount = moveCount + globalListLength End If
    If list(index).value < 0 Then moveCount = moveCount - 1 End If

    extractIndex list(), index

    Dim current As Integer = list(index).nextn
    'Dim current As Integer = index
    For i As Integer = 1 To moveCount
        current = list(current).nextn
    Next i

    insertJustBefore list(), index, current

    Print "Moved " & list(index).value & " between " & list(list(index).prevn).value & " and " & list(list(index).nextn).value
End Sub

' Output Functions
Function getIndexOfZero( list() As ListNode ) as Integer
    For i As Integer = 1 To globalListLength
        If list(i).value = 0 Then
            Return i
        End If
    Next i
    Return 0
End Function

Function groveSum( list() As ListNode ) as Integer<64>
    Dim res As Integer<64> = 0
    Dim current As Integer = getIndexOfZero(list())
    For thousand As Integer = 1 To 3
        For i As Integer = 1 to 1000
            current = list(current).nextn
        Next i
        Print "Grovesum += " & list(current).value
        res = res + list(current).value
    Next thousand
    Return res
End Function

' Main
populateInputLists
For i As Integer = 1 To globalListLength
    mixOneNode inputListP1(), i

    'Print "Mixing " & inputListP1(i).value & "..."
    'Print "== List Status =="
    'Dim current As Integer = 1
    'For tmp As Integer = 1 To 7
        'Print inputListP1(current).value
        'current = inputListP1(current).nextn
    'Next tmp
Next i

Dim res as Integer = groveSum(inputListP1())
Print "Res=" & res
