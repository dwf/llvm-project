; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin19.5.0 | FileCheck %s

; OSS fuzz: https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=25184

define <2 x double> @test_fpext() {
; CHECK-LABEL: test_fpext:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = [4.9406564584124654E-324,0.0E+0]
; CHECK-NEXT:    retq
  %tmp12 = insertelement <4 x float> undef, float 0.000000e+00, i32 3
  %tmp5 = fpext <4 x float> %tmp12 to <4 x double>
  %ret = shufflevector <4 x double> %tmp5, <4 x double> undef, <2 x i32> <i32 0, i32 1>
  %E1 = extractelement <4 x double> %tmp5, i16 undef
  %I2 = insertelement <2 x double> %ret, double 4.940660e-324, i16 undef
  store double %E1, double* undef, align 8
  ret <2 x double> %I2
}
