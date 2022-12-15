import data from "./data.json";
import "./App.css";
import React, { useMemo } from "react";
import { useState } from "react";
import { useEffect } from "react";
import Chart from "./components/Chart";
import colores from "./constants/colors";
import { useRef } from "react";

function App() {
  const [start, setStart] = useState(false);
  const [segundos, setSegundos] = useState(0);
  const [selected, setSelected] = useState(null);

  const handleStart = () => setStart(!start);
  const handleRestart = () => setSegundos(0);
  const handleUnselect = () => setSelected(null);

  const values = useMemo(() => {
    const valoresFinales = {};
    let count = 0;

    for (let i = 0; i < data.filas; i++) {
      for (let j = 0; j < data.columnas; j++) {
        valoresFinales[count] = {
          expuestos: [],
          infectados: [],
          suceptibles: [],
          recuperados: [],
          total_muertos: [],
          total_poblacion: [],
        };
        count++;
      }
    }

    for (let s = 0; s < data.segundos; s++) {
      count = 0;
      for (let i = 0; i < data.filas; i++) {
        for (let j = 0; j < data.columnas; j++) {
          valoresFinales[count].expuestos.push(data.data[s][count].expuestos);
          valoresFinales[count].infectados.push(data.data[s][count].infectados);
          valoresFinales[count].suceptibles.push(
            data.data[s][count].suceptibles
          );
          valoresFinales[count].recuperados.push(
            data.data[s][count].recuperados
          );
          valoresFinales[count].total_muertos.push(
            data.data[s][count].total_muertos
          );
          valoresFinales[count].total_poblacion.push(
            data.data[s][count].total_poblacion
          );
          count++;
        }
      }
    }

    return { data: valoresFinales };
  }, [data.filas, data.columnas, segundos]);

  const valuesGrid = useMemo(() => {
    if (!Object.keys(values.data).length) return;

    let vecindades = [];
    const total = [];

    for (let i = 0; i < data.filas * data.columnas; i += 1) {
      const infectadosIniciales = values.data[i].infectados[0];
      const infectadosActuales = values.data[i].infectados[segundos];
      const element = (
        <div
          className="vecindad"
          onClick={() => setSelected(values.data[i])}
          style={{
            backgroundColor: `${colores[i]}`,
            opacity:
              infectadosIniciales > infectadosActuales
                ? 0.3
                : infectadosIniciales < infectadosActuales
                ? 0.9
                : 0.7,
          }}
          key={`${i}`}
        />
      );
      vecindades.push(element);

      if ((i + 1) % data.filas === 0) {
        total.push(
          <div className="fila" key={i}>
            {vecindades}
          </div>
        );
        vecindades = [];
      }
    }

    return total;
  }, [segundos, values, values.data]);

  useEffect(() => {
    if (start) {
      if (segundos !== data.segundos - 1) {
        setTimeout(() => {
          setSegundos(segundos + 1);
        }, 1000);
      } else {
        setStart(false);
      }
    }
  }, [start, segundos]);

  return (
    <div className="App">
      <div className="graficos">
        <Chart
          labels={Array(data.segundos)
            .fill()
            .map((_, index) => index)}
          datasets={
            segundos === 0
              ? selected
                ? [selected.infectados]
                : Object.entries(values.data).map(([_, value]) => {
                    return value.infectados;
                  })
              : selected
              ? [selected.infectados]
              : Object.entries(values.data).map(([_, value]) => {
                  return value.infectados.slice(0, segundos + 1);
                })
          }
          titleText="Cantidad de infectados por vecindario a través del tiempo"
          yLabel="Cantidad de infectados"
          xLabel="Ciclos"
          type="line"
          minY={0}
        />
        <Chart
          labels={Array(data.segundos)
            .fill()
            .map((_, index) => index)}
          datasets={
            segundos === 0
              ? selected
                ? [selected.suceptibles]
                : Object.entries(values.data).map(([_, value]) => {
                    return value.suceptibles;
                  })
              : selected
              ? [selected.suceptibles.slice(0, segundos + 1)]
              : Object.entries(values.data).map(([_, value]) => {
                  return value.suceptibles.slice(0, segundos + 1);
                })
          }
          titleText="Cantidad de suceptibles por vecindario a través del tiempo"
          yLabel="Cantidad de suceptibles"
          xLabel="Ciclos"
          type="line"
          minY={0}
        />
        <Chart
          labels={Array(data.segundos)
            .fill()
            .map((_, index) => index)}
          datasets={
            segundos === 0
              ? selected
                ? [selected.expuestos]
                : Object.entries(values.data).map(([_, value]) => {
                    return value.expuestos;
                  })
              : selected
              ? [selected.expuestos.slice(0, segundos + 1)]
              : Object.entries(values.data).map(([_, value]) => {
                  return value.expuestos.slice(0, segundos + 1);
                })
          }
          titleText="Cantidad de expuestos por vecindario a través del tiempo"
          yLabel="Cantidad de expuestos"
          xLabel="Ciclos"
          minY={0}
          type="line"
        />
        <Chart
          labels={Array(data.segundos)
            .fill()
            .map((_, index) => index)}
          datasets={
            segundos === 0
              ? selected
                ? [selected.recuperados]
                : Object.entries(values.data).map(([_, value]) => {
                    return value.recuperados;
                  })
              : selected
              ? [selected.recuperados.slice(0, segundos + 1)]
              : Object.entries(values.data).map(([_, value]) => {
                  return value.recuperados.slice(0, segundos + 1);
                })
          }
          titleText="Cantidad de recuperados por vecindario a través del tiempo"
          yLabel="Cantidad de recuperados"
          xLabel="Ciclos"
          type="line"
          minY={0}
        />
        <Chart
          labels={Array(data.segundos)
            .fill()
            .map((_, index) => index)}
          datasets={
            segundos === 0
              ? selected
                ? [selected.total_muertos]
                : Object.entries(values.data).map(([_, value]) => {
                    return value.total_muertos;
                  })
              : selected
              ? [selected.total_muertos.slice(0, segundos + 1)]
              : Object.entries(values.data).map(([_, value]) => {
                  return value.total_muertos.slice(0, segundos + 1);
                })
          }
          titleText="Cantidad de muertos por vecindario a través del tiempo"
          yLabel="Cantidad de muertos"
          xLabel="Ciclos"
          type="line"
          minY={0}
        />
        <Chart
          labels={Array(data.segundos)
            .fill()
            .map((_, index) => index)}
          datasets={
            segundos === 0
              ? selected
                ? [selected.total_poblacion]
                : Object.entries(values.data).map(([_, value]) => {
                    return value.total_poblacion;
                  })
              : selected
              ? [selected.total_poblacion.slice(0, segundos + 1)]
              : Object.entries(values.data).map(([_, value]) => {
                  return value.total_poblacion.slice(0, segundos + 1);
                })
          }
          titleText="Cantidad de población por vecindario a través del tiempo"
          yLabel="Cantidad de población"
          xLabel="Ciclos"
          type="line"
          minY={0}
        />
      </div>
      <div>Segundo: {segundos}</div>
      <div className="grilla">{valuesGrid}</div>
      <div className="botones">
        <button onClick={handleStart}>{start ? "Stop" : "Start"}</button>
        <button onClick={handleRestart}>Restart</button>
        <button onClick={handleUnselect}>Unselect</button>
      </div>
    </div>
  );
}

export default App;
