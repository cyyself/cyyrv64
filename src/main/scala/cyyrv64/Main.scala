package cyyrv64

import chisel3._
import chisel3.stage.{ChiselGeneratorAnnotation, ChiselStage}

object Main extends App{
    (new ChiselStage).execute(Array.empty, Seq(ChiselGeneratorAnnotation(() => new Mul)))
}