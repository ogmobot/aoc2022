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

' Helper functions
Sub populateInputLists
    Dim s As String
    Redim inputListP1(1 To globalListLength)
    Redim inputListP2(1 To globalListLength)
    Open "input20.txt" For Input As #1
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
    Dim moveCount As Integer = list(index).value Mod globalListLength
    If moveCount < 0 Then moveCount = moveCount + globalListLength End If

    extractIndex list(), index

    Dim current As Integer = list(index).nextn
    For i As Integer = 1 To moveCount
        current = list(current).nextn
    Next i

    insertJustBefore list(), index, current
End Sub

Sub insertAt ( list() As ListNode, index As Integer, dest As Integer )
    ' Inserts inputList[index] into the doubly-linked list at index `dest`
End Sub

' Main
populateInputLists
extractIndex inputListP1(), 1
print inputListP1(1).value
