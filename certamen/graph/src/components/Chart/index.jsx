import React from "react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Colors,
} from "chart.js";
import { Line } from "react-chartjs-2";
import colores from "../../constants/colors";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const Chart = ({
  height,
  width,
  labels,
  datasets: datasetsReceived,
  titleText,
  xLabel,
  yLabel,
  minX,
  minY,
  maxX,
  maxY,
  type,
}) => {
  const options = {
    responsive: true,
    animation: false,
    hover: {
      animationDuration: 0, // duration of animations when hovering an item
    },
    responsiveAnimationDuration: 0, // animation duration after a resize
    plugins: {
      legend: {
        position: "top",
        labels: {
          font: {
            size: 22,
          },
        },
      },
      title: {
        display: true,
        text: titleText,
        font: {
          size: 25,
        },
      },
    },
    scales: {
      x: {
        display: true,
        title: {
          display: true,
          text: xLabel,
          font: {
            size: 24,
          },
        },
        ticks: {
          font: {
            size: 20,
          },
        },
        min: minX,
        max: maxX,
      },
      y: {
        display: true,
        title: {
          display: true,
          text: yLabel,
          font: {
            size: 24,
          },
        },
        ticks: {
          font: {
            size: 20,
          },
        },
        min: minY,
        max: maxY,
      },
    },
  };

  const data = {
    labels,
    datasets: datasetsReceived.map((dataset, index) => {
      return {
        label: `Vecindario ${index}`,
        data: dataset,
        borderColor: colores[index],
        backgroundColor: colores[index],
      };
    }),
  };

  if (type === "line")
    return (
      <Line
        className="grafico"
        height={height}
        width={width}
        options={options}
        data={data}
      />
    );

  return <p>no cargado</p>;
};

export default Chart;
