; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=i386-unknown-linux-gnu -mattr=-slow-incdec < %s | FileCheck -check-prefix=CHECK -check-prefix=INCDEC %s
; RUN: llc -mtriple=i386-unknown-linux-gnu -mattr=+slow-incdec < %s | FileCheck -check-prefix=CHECK -check-prefix=ADD %s

define i32 @inc(i32 %x) {
; INCDEC-LABEL: inc:
; INCDEC:       # %bb.0:
; INCDEC-NEXT:    movl {{[0-9]+}}(%esp), %eax
; INCDEC-NEXT:    incl %eax
; INCDEC-NEXT:    retl
;
; ADD-LABEL: inc:
; ADD:       # %bb.0:
; ADD-NEXT:    movl {{[0-9]+}}(%esp), %eax
; ADD-NEXT:    addl $1, %eax
; ADD-NEXT:    retl
  %r = add i32 %x, 1
  ret i32 %r
}

define i32 @dec(i32 %x) {
; INCDEC-LABEL: dec:
; INCDEC:       # %bb.0:
; INCDEC-NEXT:    movl {{[0-9]+}}(%esp), %eax
; INCDEC-NEXT:    decl %eax
; INCDEC-NEXT:    retl
;
; ADD-LABEL: dec:
; ADD:       # %bb.0:
; ADD-NEXT:    movl {{[0-9]+}}(%esp), %eax
; ADD-NEXT:    addl $-1, %eax
; ADD-NEXT:    retl
  %r = add i32 %x, -1
  ret i32 %r
}

define i32 @inc_size(i32 %x) optsize {
; CHECK-LABEL: inc_size:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    incl %eax
; CHECK-NEXT:    retl
  %r = add i32 %x, 1
  ret i32 %r
}

define i32 @dec_size(i32 %x) optsize {
; CHECK-LABEL: dec_size:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    decl %eax
; CHECK-NEXT:    retl
  %r = add i32 %x, -1
  ret i32 %r
}

define i32 @inc_pgso(i32 %x) !prof !14 {
; CHECK-LABEL: inc_pgso:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    incl %eax
; CHECK-NEXT:    retl
  %r = add i32 %x, 1
  ret i32 %r
}

define i32 @dec_pgso(i32 %x) !prof !14 {
; CHECK-LABEL: dec_pgso:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    decl %eax
; CHECK-NEXT:    retl
  %r = add i32 %x, -1
  ret i32 %r
}

declare {i32, i1} @llvm.uadd.with.overflow.i32(i32, i32)
declare void @other(i32* ) nounwind;

define void @cond_ae_to_cond_ne(i32* %p) nounwind {
; INCDEC-LABEL: cond_ae_to_cond_ne:
; INCDEC:       # %bb.0: # %entry
; INCDEC-NEXT:    movl {{[0-9]+}}(%esp), %eax
; INCDEC-NEXT:    incl (%eax)
; INCDEC-NEXT:    je other@PLT # TAILCALL
; INCDEC-NEXT:  # %bb.1: # %return
; INCDEC-NEXT:    retl
;
; ADD-LABEL: cond_ae_to_cond_ne:
; ADD:       # %bb.0: # %entry
; ADD-NEXT:    movl {{[0-9]+}}(%esp), %eax
; ADD-NEXT:    addl $1, (%eax)
; ADD-NEXT:    je other@PLT # TAILCALL
; ADD-NEXT:  # %bb.1: # %return
; ADD-NEXT:    retl
entry:
  %t0 = load i32, i32* %p, align 8
  %add_ov = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %t0, i32 1)
  %inc = extractvalue { i32, i1 } %add_ov, 0
  store i32 %inc, i32* %p, align 8
  %ov = extractvalue { i32, i1 } %add_ov, 1
  br i1 %ov, label %if.end4, label %return

if.end4:
  tail call void @other(i32* %p) nounwind
  br label %return

return:
  ret void
}

@a = common global i8 0, align 1
@d = common global i8 0, align 1

declare void @external_a()
declare void @external_b()
declare {i8, i1} @llvm.uadd.with.overflow.i8(i8, i8)

define void @test_tail_call(i32* %ptr) nounwind {
; INCDEC-LABEL: test_tail_call:
; INCDEC:       # %bb.0: # %entry
; INCDEC-NEXT:    movl {{[0-9]+}}(%esp), %eax
; INCDEC-NEXT:    incl (%eax)
; INCDEC-NEXT:    setne %al
; INCDEC-NEXT:    incb a
; INCDEC-NEXT:    sete d
; INCDEC-NEXT:    testb %al, %al
; INCDEC-NEXT:    jne external_b@PLT # TAILCALL
; INCDEC-NEXT:  # %bb.1: # %then
; INCDEC-NEXT:    jmp external_a@PLT # TAILCALL
;
; ADD-LABEL: test_tail_call:
; ADD:       # %bb.0: # %entry
; ADD-NEXT:    movl {{[0-9]+}}(%esp), %eax
; ADD-NEXT:    addl $1, (%eax)
; ADD-NEXT:    setne %al
; ADD-NEXT:    addb $1, a
; ADD-NEXT:    sete d
; ADD-NEXT:    testb %al, %al
; ADD-NEXT:    jne external_b@PLT # TAILCALL
; ADD-NEXT:  # %bb.1: # %then
; ADD-NEXT:    jmp external_a@PLT # TAILCALL
entry:
  %val = load i32, i32* %ptr
  %add_ov = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %val, i32 1)
  %inc = extractvalue { i32, i1 } %add_ov, 0
  store i32 %inc, i32* %ptr
  %cmp = extractvalue { i32, i1 } %add_ov, 1
  %aval = load volatile i8, i8* @a
  %add_ov2 = call {i8, i1} @llvm.uadd.with.overflow.i8(i8 %aval, i8 1)
  %inc2 = extractvalue { i8, i1 } %add_ov2, 0
  store volatile i8 %inc2, i8* @a
  %cmp2 = extractvalue { i8, i1 } %add_ov2, 1
  %conv5 = zext i1 %cmp2 to i8
  store i8 %conv5, i8* @d
  br i1 %cmp, label %then, label %else

then:
  tail call void @external_a()
  ret void

else:
  tail call void @external_b()
  ret void
}

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"ProfileSummary", !1}
!1 = !{!2, !3, !4, !5, !6, !7, !8, !9}
!2 = !{!"ProfileFormat", !"InstrProf"}
!3 = !{!"TotalCount", i64 10000}
!4 = !{!"MaxCount", i64 10}
!5 = !{!"MaxInternalCount", i64 1}
!6 = !{!"MaxFunctionCount", i64 1000}
!7 = !{!"NumCounts", i64 3}
!8 = !{!"NumFunctions", i64 3}
!9 = !{!"DetailedSummary", !10}
!10 = !{!11, !12, !13}
!11 = !{i32 10000, i64 100, i32 1}
!12 = !{i32 999000, i64 100, i32 1}
!13 = !{i32 999999, i64 1, i32 2}
!14 = !{!"function_entry_count", i64 0}
